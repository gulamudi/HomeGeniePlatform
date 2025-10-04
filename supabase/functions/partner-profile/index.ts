import { corsHeaders, handleCORS, createResponse, createErrorResponse, validateRequestBody, createSupabaseClient, getAuthUser } from '../_shared/utils.ts';
import { UpdatePartnerProfileRequestSchema, UploadDocumentRequestSchema, UpdateAvailabilityRequestSchema, HTTP_STATUS, API_MESSAGES } from '../_shared/types.ts';

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
    const url = new URL(req.url);

    // Verify user is a partner
    const { data: userProfile } = await supabase
      .from('users')
      .select('user_type')
      .eq('id', user.id)
      .single();

    if (!userProfile || userProfile.user_type !== 'partner') {
      return createErrorResponse(
        'Access denied',
        HTTP_STATUS.FORBIDDEN
      );
    }

    if (req.method === 'GET') {
      const path = url.pathname;

      if (path.includes('/verification')) {
        // Get verification status
        const { data: partnerProfile, error } = await supabase
          .from('partner_profiles')
          .select('verification_status, documents')
          .eq('user_id', user.id)
          .single();

        if (error) {
          console.error('Error fetching verification status:', error);
          return createErrorResponse(
            'Failed to fetch verification status',
            HTTP_STATUS.INTERNAL_SERVER_ERROR
          );
        }

        return createResponse(
          {
            overallStatus: partnerProfile?.verification_status || 'pending',
            documents: partnerProfile?.documents || [],
          },
          HTTP_STATUS.OK
        );

      } else {
        // Get partner profile
        const { data: partnerProfile, error } = await supabase
          .from('users')
          .select('*, partner_profiles(*)')
          .eq('id', user.id)
          .single();

        if (error) {
          console.error('Error fetching partner profile:', error);
          return createErrorResponse(
            'Failed to fetch profile',
            HTTP_STATUS.INTERNAL_SERVER_ERROR
          );
        }

        return createResponse(partnerProfile, HTTP_STATUS.OK);
      }

    } else if (req.method === 'PUT') {
      const path = url.pathname;

      if (path.includes('/availability')) {
        // Update availability
        const validation = await validateRequestBody(req, UpdateAvailabilityRequestSchema);
        if (!validation.success) {
          return createErrorResponse(validation.error, HTTP_STATUS.BAD_REQUEST);
        }

        const { isAvailable, workingHours, weekdays } = validation.data;

        // Get current availability
        const { data: currentProfile } = await supabase
          .from('partner_profiles')
          .select('availability')
          .eq('user_id', user.id)
          .single();

        const currentAvailability = currentProfile?.availability || {};
        const updatedAvailability = {
          ...currentAvailability,
          ...(isAvailable !== undefined && { isAvailable }),
          ...(workingHours && { workingHours }),
          ...(weekdays && { weekdays }),
        };

        const { error: updateError } = await supabase
          .from('partner_profiles')
          .update({ availability: updatedAvailability })
          .eq('user_id', user.id);

        if (updateError) {
          console.error('Error updating availability:', updateError);
          return createErrorResponse(
            'Failed to update availability',
            HTTP_STATUS.INTERNAL_SERVER_ERROR
          );
        }

        return createResponse(
          {},
          HTTP_STATUS.OK,
          'Availability updated successfully'
        );

      } else {
        // Update partner profile
        const validation = await validateRequestBody(req, UpdatePartnerProfileRequestSchema);
        if (!validation.success) {
          return createErrorResponse(validation.error, HTTP_STATUS.BAD_REQUEST);
        }

        const updateData = validation.data;

        // Update partner profile
        const { data: updatedProfile, error: updateError } = await supabase
          .from('partner_profiles')
          .update(updateData)
          .eq('user_id', user.id)
          .select('*')
          .single();

        if (updateError) {
          console.error('Error updating partner profile:', updateError);
          return createErrorResponse(
            'Failed to update profile',
            HTTP_STATUS.INTERNAL_SERVER_ERROR
          );
        }

        return createResponse(
          updatedProfile,
          HTTP_STATUS.OK,
          API_MESSAGES.PROFILE_UPDATED
        );
      }

    } else if (req.method === 'POST') {
      const path = url.pathname;

      if (path.includes('/documents')) {
        // Upload document
        const validation = await validateRequestBody(req, UploadDocumentRequestSchema);
        if (!validation.success) {
          return createErrorResponse(validation.error, HTTP_STATUS.BAD_REQUEST);
        }

        const { type, fileUrl } = validation.data;

        // Get current documents
        const { data: currentProfile } = await supabase
          .from('partner_profiles')
          .select('documents')
          .eq('user_id', user.id)
          .single();

        const currentDocuments = currentProfile?.documents || [];
        const documentId = crypto.randomUUID();

        // Remove existing document of same type
        const filteredDocuments = currentDocuments.filter((doc: any) => doc.type !== type);

        // Add new document
        const newDocument = {
          id: documentId,
          type,
          url: fileUrl,
          status: 'pending',
          uploadedAt: new Date().toISOString(),
        };

        const updatedDocuments = [...filteredDocuments, newDocument];

        // Update documents
        const { error: updateError } = await supabase
          .from('partner_profiles')
          .update({ documents: updatedDocuments })
          .eq('user_id', user.id);

        if (updateError) {
          console.error('Error uploading document:', updateError);
          return createErrorResponse(
            'Failed to upload document',
            HTTP_STATUS.INTERNAL_SERVER_ERROR
          );
        }

        return createResponse(
          {
            documentId,
            status: 'pending',
          },
          HTTP_STATUS.CREATED,
          'Document uploaded successfully'
        );
      }
    }

    return createErrorResponse('Method not allowed', HTTP_STATUS.NOT_FOUND);

  } catch (error) {
    console.error('Partner profile operation error:', error);
    return createErrorResponse(
      API_MESSAGES.INTERNAL_ERROR,
      HTTP_STATUS.INTERNAL_SERVER_ERROR
    );
  }
});