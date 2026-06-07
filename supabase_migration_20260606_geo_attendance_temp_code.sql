-- Create dedicated table for temporary verification codes
CREATE TABLE IF NOT EXISTS public.geo_attendance_codes (
  room_id uuid NOT NULL,
  code text NOT NULL,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT geo_attendance_codes_pkey PRIMARY KEY (room_id),
  CONSTRAINT geo_attendance_codes_room_fkey FOREIGN KEY (room_id) REFERENCES public.geo_attendance_rooms(id) ON DELETE CASCADE
);

-- Trigger function to automatically delete verification code on room deactivation/expiration
CREATE OR REPLACE FUNCTION public.delete_expired_geo_attendance_code()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.is_active = false AND OLD.is_active = true THEN
    DELETE FROM public.geo_attendance_codes WHERE room_id = NEW.id;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger definition on geo_attendance_rooms
CREATE OR REPLACE TRIGGER delete_code_on_deactivation
  AFTER UPDATE OF is_active ON public.geo_attendance_rooms
  FOR EACH ROW
  EXECUTE FUNCTION public.delete_expired_geo_attendance_code();
