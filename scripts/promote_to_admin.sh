#!/bin/bash

# Script to promote a user to admin
# Usage: ./scripts/promote_to_admin.sh +917777777777 super_admin

PHONE=$1
ROLE=${2:-admin}

if [ -z "$PHONE" ]; then
    echo "Usage: $0 <phone_number> [role]"
    echo "Example: $0 +917777777777 super_admin"
    exit 1
fi

echo "Promoting $PHONE to $ROLE..."

docker exec supabase_db_homegenie-platform psql -U postgres -c "
SELECT public.promote_user_to_admin('$PHONE', '$ROLE');
SELECT u.id, u.phone, u.user_type, u.full_name, au.role
FROM public.users u
LEFT JOIN public.admin_users au ON u.id = au.user_id
WHERE u.phone = '$PHONE';
"

echo "Done!"
