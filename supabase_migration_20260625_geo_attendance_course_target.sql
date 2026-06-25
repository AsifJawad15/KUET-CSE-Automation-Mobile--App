-- Migration: store geo-attendance course targeting on the room row.
-- This lets mobile clients show active rooms even when nested PostgREST
-- course_offerings/courses joins are unavailable because of RLS or schema cache.

ALTER TABLE public.geo_attendance_rooms
  ADD COLUMN IF NOT EXISTS course_code text,
  ADD COLUMN IF NOT EXISTS target_term text;

UPDATE public.geo_attendance_rooms gar
SET
  course_code = COALESCE(gar.course_code, upper(trim(c.code))),
  target_term = COALESCE(
    gar.target_term,
    CASE
      WHEN substring(regexp_replace(c.code, '\D', '', 'g') from 1 for 2)
           ~ '^[1-4][1-2]$'
      THEN
        substring(regexp_replace(c.code, '\D', '', 'g') from 1 for 1)
        || '-'
        || substring(regexp_replace(c.code, '\D', '', 'g') from 2 for 1)
      ELSE co.term
    END
  )
FROM public.course_offerings co
JOIN public.courses c ON c.id = co.course_id
WHERE gar.offering_id = co.id
  AND (gar.course_code IS NULL OR gar.target_term IS NULL);

CREATE INDEX IF NOT EXISTS idx_geo_attendance_rooms_course_code
  ON public.geo_attendance_rooms(course_code);

CREATE INDEX IF NOT EXISTS idx_geo_attendance_rooms_target_term_active
  ON public.geo_attendance_rooms(target_term, is_active);
