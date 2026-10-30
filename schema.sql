-- TEXNO BOZORI: Supabase > SQL Editor ga to'liq qo'yib "Run" bosing
create table profiles(id uuid primary key references auth.users on delete cascade,name text,phone text,telegram text,role text not null default 'user' check(role in('user','admin')),created_at timestamptz default now());
create function handle_new_user() returns trigger language plpgsql security definer set search_path=public as $$
begin insert into profiles(id,name,phone,telegram) values(new.id,left(new.raw_user_meta_data->>'name',80),left(new.raw_user_meta_data->>'phone',30),left(new.raw_user_meta_data->>'telegram',40)); return new; end $$;
create trigger on_auth_user_created after insert on auth.users for each row execute function handle_new_user();
create function is_admin() returns boolean language sql security definer stable set search_path=public as $$ select exists(select 1 from profiles where id=auth.uid() and role='admin') $$;
create table listings(id bigint generated always as identity primary key,user_id uuid not null default auth.uid() references profiles(id) on delete cascade,cat text not null,title text not null check(char_length(title) between 3 and 120),descr text check(char_length(descr)<=3000),price numeric(12,2) not null check(price>=0),cond text not null default 'used' check(cond in('new','used')),city text not null,district text,images text[] not null default '{}',status text not null default 'active' check(status in('active','hidden')),created_at timestamptz default now());
create index on listings(cat,created_at desc); create index on listings(city);
create table favorites(user_id uuid not null default auth.uid() references profiles(id) on delete cascade,listing_id bigint references listings(id) on delete cascade,primary key(user_id,listing_id));
create table reports(id bigint generated always as identity primary key,listing_id bigint references listings(id) on delete cascade,user_id uuid default auth.uid() references profiles(id) on delete set null,reason text not null check(char_length(reason) between 3 and 500),resolved boolean not null default false,created_at timestamptz default now());
alter table profiles enable row level security; alter table listings enable row level security; alter table favorites enable row level security; alter table reports enable row level security;
create policy p_sel on profiles for select using(true);
create policy p_upd on profiles for update using(id=auth.uid());
revoke update on profiles from authenticated,anon; grant update(name,phone,telegram) on profiles to authenticated;
create policy l_sel on listings for select using(status='active' or user_id=auth.uid() or is_admin());
create policy l_ins on listings for insert to authenticated with check(user_id=auth.uid());
create policy l_upd on listings for update to authenticated using(user_id=auth.uid() or is_admin());
create policy l_del on listings for delete to authenticated using(user_id=auth.uid() or is_admin());
revoke update on listings from authenticated; grant update(cat,title,descr,price,cond,city,district,images) on listings to authenticated;
create function admin_set_status(lid bigint,s text) returns void language plpgsql security definer set search_path=public as $$
begin if not is_admin() then raise exception 'denied'; end if; update listings set status=s where id=lid; end $$;
create policy f_all on favorites for all to authenticated using(user_id=auth.uid()) with check(user_id=auth.uid());
create policy r_ins on reports for insert to authenticated with check(user_id=auth.uid());
create policy r_sel on reports for select to authenticated using(is_admin());
create policy r_upd on reports for update to authenticated using(is_admin());
revoke update on reports from authenticated; grant update(resolved) on reports to authenticated;
insert into storage.buckets(id,name,public,file_size_limit,allowed_mime_types) values('images','images',true,2097152,array['image/jpeg','image/png','image/webp']) on conflict do nothing;
create policy i_sel on storage.objects for select using(bucket_id='images');
create policy i_ins on storage.objects for insert to authenticated with check(bucket_id='images' and (storage.foldername(name))[1]=auth.uid()::text);
create policy i_del on storage.objects for delete to authenticated using(bucket_id='images' and ((storage.foldername(name))[1]=auth.uid()::text or is_admin()));
-- ADMIN tayinlash (ro'yxatdan o'tgach, emailingizni yozing):
-- update profiles set role='admin' where id=(select id from auth.users where email='SIZNING@EMAIL');
