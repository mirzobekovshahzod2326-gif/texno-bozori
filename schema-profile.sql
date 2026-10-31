-- Profil rasmi uchun. Supabase > SQL Editor ga qo'yib Run bosing.
alter table profiles add column if not exists avatar_url text;
revoke update on profiles from authenticated;
grant update(name,phone,telegram,avatar_url) on profiles to authenticated;
