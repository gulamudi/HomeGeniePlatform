import { corsHeaders, handleCORS, createResponse, createErrorResponse, validateRequestBody, createSupabaseClient, getAuthUser } from '../_shared/utils.ts';
import { AddAddressRequestSchema, UpdateAddressRequestSchema, DeleteAddressRequestSchema, HTTP_STATUS, API_MESSAGES } from '../_shared/types.ts';

Deno.serve(async (req) => {
  // Handle CORS
  const corsResponse = handleCORS(req);
  if (corsResponse) return corsResponse;

  try {
    // Get authenticated user
    const user = await getAuthUser(req);
    if (!user) {
      return createErrorResponse(
        API_MESSAGES.UNAUTHORIZED,
        HTTP_STATUS.UNAUTHORIZED
      );
    }

    const supabase = createSupabaseClient();

    // Verify user is a customer
    const { data: userProfile } = await supabase
      .from('users')
      .select('user_type')
      .eq('id', user.id)
      .single();

    if (!userProfile || userProfile.user_type !== 'customer') {
      return createErrorResponse(
        'Access denied',
        HTTP_STATUS.FORBIDDEN
      );
    }

    if (req.method === 'GET') {
      // Get all addresses
      const { data: customerProfile, error } = await supabase
        .from('customer_profiles')
        .select('addresses')
        .eq('user_id', user.id)
        .single();

      if (error) {
        console.error('Error fetching addresses:', error);
        return createErrorResponse(
          'Failed to fetch addresses',
          HTTP_STATUS.INTERNAL_SERVER_ERROR
        );
      }

      return createResponse(
        customerProfile?.addresses || [],
        HTTP_STATUS.OK
      );

    } else if (req.method === 'POST') {
      // Add new address
      const validation = await validateRequestBody(req, AddAddressRequestSchema);
      if (!validation.success) {
        return createErrorResponse(validation.error, HTTP_STATUS.BAD_REQUEST);
      }

      const addressData = validation.data as any;
      const newAddress = {
        id: crypto.randomUUID(),
        flatHouseNo: addressData.flatHouseNo,
        buildingApartmentName: addressData.buildingApartmentName,
        streetName: addressData.streetName,
        landmark: addressData.landmark,
        area: addressData.area,
        city: addressData.city,
        state: addressData.state,
        pinCode: addressData.pinCode,
        type: addressData.type || 'home',
        isDefault: addressData.isDefault || false,
      };

      // Get current addresses
      const { data: currentProfile, error: fetchError } = await supabase
        .from('customer_profiles')
        .select('addresses')
        .eq('user_id', user.id)
        .single();

      if (fetchError) {
        console.error('Error fetching current addresses:', fetchError);
        return createErrorResponse(
          'Failed to fetch current addresses',
          HTTP_STATUS.INTERNAL_SERVER_ERROR
        );
      }

      const currentAddresses = currentProfile?.addresses || [];

      // If this is set as default, unset other defaults
      let updatedAddresses = currentAddresses;
      if (newAddress.isDefault) {
        updatedAddresses = currentAddresses.map((addr: any) => ({
          ...addr,
          isDefault: false,
        }));
      }

      updatedAddresses.push(newAddress);

      // Update addresses
      const { error: updateError } = await supabase
        .from('customer_profiles')
        .update({ addresses: updatedAddresses })
        .eq('user_id', user.id);

      if (updateError) {
        console.error('Error adding address:', updateError);
        return createErrorResponse(
          'Failed to add address',
          HTTP_STATUS.INTERNAL_SERVER_ERROR
        );
      }

      return createResponse(
        newAddress,
        HTTP_STATUS.CREATED,
        'Address added successfully'
      );

    } else if (req.method === 'PUT') {
      // Update address
      const validation = await validateRequestBody(req, UpdateAddressRequestSchema);
      if (!validation.success) {
        return createErrorResponse(validation.error, HTTP_STATUS.BAD_REQUEST);
      }

      const { id: addressId, ...updateData } = validation.data;

      // Get current addresses
      const { data: currentProfile, error: fetchError } = await supabase
        .from('customer_profiles')
        .select('addresses')
        .eq('user_id', user.id)
        .single();

      if (fetchError) {
        console.error('Error fetching current addresses:', fetchError);
        return createErrorResponse(
          'Failed to fetch current addresses',
          HTTP_STATUS.INTERNAL_SERVER_ERROR
        );
      }

      const currentAddresses = currentProfile?.addresses || [];
      const addressIndex = currentAddresses.findIndex((addr: any) => addr.id === addressId);

      if (addressIndex === -1) {
        return createErrorResponse(
          'Address not found',
          HTTP_STATUS.NOT_FOUND
        );
      }

      // Build the update object with proper camelCase field names
      const addressUpdate: any = {};
      if (updateData.flatHouseNo !== undefined) addressUpdate.flatHouseNo = updateData.flatHouseNo;
      if (updateData.buildingApartmentName !== undefined) addressUpdate.buildingApartmentName = updateData.buildingApartmentName;
      if (updateData.streetName !== undefined) addressUpdate.streetName = updateData.streetName;
      if (updateData.landmark !== undefined) addressUpdate.landmark = updateData.landmark;
      if (updateData.area !== undefined) addressUpdate.area = updateData.area;
      if (updateData.city !== undefined) addressUpdate.city = updateData.city;
      if (updateData.state !== undefined) addressUpdate.state = updateData.state;
      if (updateData.pinCode !== undefined) addressUpdate.pinCode = updateData.pinCode;
      if (updateData.type !== undefined) addressUpdate.type = updateData.type;
      if (updateData.isDefault !== undefined) addressUpdate.isDefault = updateData.isDefault;

      // Update the address
      let updatedAddresses = [...currentAddresses];
      updatedAddresses[addressIndex] = {
        ...updatedAddresses[addressIndex],
        ...addressUpdate,
      };

      // If this is set as default, unset other defaults
      if (addressUpdate.isDefault) {
        updatedAddresses = updatedAddresses.map((addr: any, index: number) => ({
          ...addr,
          isDefault: index === addressIndex,
        }));
      }

      // Update addresses
      const { error: updateError } = await supabase
        .from('customer_profiles')
        .update({ addresses: updatedAddresses })
        .eq('user_id', user.id);

      if (updateError) {
        console.error('Error updating address:', updateError);
        return createErrorResponse(
          'Failed to update address',
          HTTP_STATUS.INTERNAL_SERVER_ERROR
        );
      }

      return createResponse(
        updatedAddresses[addressIndex],
        HTTP_STATUS.OK,
        'Address updated successfully'
      );

    } else if (req.method === 'DELETE') {
      // Delete address
      let addressId: string;

      // Try to get addressId from request body first, then fall back to query param
      try {
        const body = await req.json();
        addressId = body.id || body.addressId;
      } catch {
        // If body parsing fails, try query parameter
        const url = new URL(req.url);
        addressId = url.searchParams.get('id') || url.searchParams.get('addressId') || '';
      }

      if (!addressId) {
        return createErrorResponse(
          'Address ID is required',
          HTTP_STATUS.BAD_REQUEST
        );
      }

      // Get current addresses
      const { data: currentProfile, error: fetchError } = await supabase
        .from('customer_profiles')
        .select('addresses')
        .eq('user_id', user.id)
        .single();

      if (fetchError) {
        console.error('Error fetching current addresses:', fetchError);
        return createErrorResponse(
          'Failed to fetch current addresses',
          HTTP_STATUS.INTERNAL_SERVER_ERROR
        );
      }

      const currentAddresses = currentProfile?.addresses || [];
      const updatedAddresses = currentAddresses.filter((addr: any) => addr.id !== addressId);

      if (updatedAddresses.length === currentAddresses.length) {
        return createErrorResponse(
          'Address not found',
          HTTP_STATUS.NOT_FOUND
        );
      }

      // Update addresses
      const { error: updateError } = await supabase
        .from('customer_profiles')
        .update({ addresses: updatedAddresses })
        .eq('user_id', user.id);

      if (updateError) {
        console.error('Error deleting address:', updateError);
        return createErrorResponse(
          'Failed to delete address',
          HTTP_STATUS.INTERNAL_SERVER_ERROR
        );
      }

      return createResponse(
        {},
        HTTP_STATUS.OK,
        'Address deleted successfully'
      );

    } else {
      return createErrorResponse('Method not allowed', HTTP_STATUS.METHOD_NOT_ALLOWED);
    }

  } catch (error) {
    console.error('Address operation error:', error);
    return createErrorResponse(
      API_MESSAGES.INTERNAL_ERROR,
      HTTP_STATUS.INTERNAL_SERVER_ERROR
    );
  }
});
