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

      const newAddress = {
        id: crypto.randomUUID(),
        ...validation.data,
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

      // Update the address
      let updatedAddresses = [...currentAddresses];
      updatedAddresses[addressIndex] = {
        ...updatedAddresses[addressIndex],
        ...updateData,
      };

      // If this is set as default, unset other defaults
      if (updateData.isDefault) {
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
      const validation = await validateRequestBody(req, DeleteAddressRequestSchema);
      if (!validation.success) {
        return createErrorResponse(validation.error, HTTP_STATUS.BAD_REQUEST);
      }

      const { addressId } = validation.data;

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
      return createErrorResponse('Method not allowed', HTTP_STATUS.NOT_FOUND);
    }

  } catch (error) {
    console.error('Address operation error:', error);
    return createErrorResponse(
      API_MESSAGES.INTERNAL_ERROR,
      HTTP_STATUS.INTERNAL_SERVER_ERROR
    );
  }
});