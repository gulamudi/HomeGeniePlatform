
CREATE OR REPLACE FUNCTION public.update_partner_rating()
RETURNS TRIGGER AS $$
DECLARE
    avg_rating DECIMAL;
    job_count INT;
BEGIN
    -- Calculate the average rating for the partner
    SELECT AVG(rating), COUNT(id)
    INTO avg_rating, job_count
    FROM public.ratings
    WHERE partner_id = NEW.partner_id;

    -- Update the partner_profiles table
    UPDATE public.partner_profiles
    SET 
        rating = COALESCE(avg_rating, 0),
        total_jobs = job_count
    WHERE user_id = NEW.partner_id;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create a trigger that fires after a new rating is inserted or updated
CREATE TRIGGER on_new_rating
AFTER INSERT OR UPDATE ON public.ratings
FOR EACH ROW
EXECUTE FUNCTION public.update_partner_rating();
