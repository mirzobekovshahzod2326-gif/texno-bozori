# ТЕХНО БОЗОРИ — ishga tushirish

Stek: statik PWA (HTML/JS) + Supabase (bepul: Postgres, Auth, Storage, RLS). Alohida server kerak emas.

## 1. Baza (Supabase, bepul)
1. supabase.com da bepul akkaunt va yangi project oching.
2. SQL Editor > `schema.sql` ni to'liq qo'yib Run bosing.
3. Authentication > Providers > Email: "Confirm email" ni o'chirsangiz, ro'yxatdan o'tgach darhol kirasiz (bepul tarifda email limiti kichik).
4. Project Settings > API: `Project URL` va `anon public` kalitni `config.js` ga yozing. `service_role` kalitni hech qayerga yozmang.

## 2. Bepul hosting (HTTPS shart: PWA uchun)
- Cloudflare Pages / Netlify: papkani (zip emas, ichidagi fayllarni) "Deploy / Upload" qiling.
- yoki GitHub Pages: fayllarni repoga yuklab, Settings > Pages.
- Supabase > Authentication > URL Configuration: Site URL ga sayt manzilingizni yozing.

## 3. Telefonga o'rnatish
- Android (Chrome): ⋮ > "Ilovani o'rnatish" / "Bosh ekranga qo'shish".
- iPhone (faqat Safari): Ulashish tugmasi > "Bosh ekranga qo'shish".

## 4. Admin
1. Saytda oddiy ro'yxatdan o'ting.
2. SQL Editor da: `update profiles set role='admin' where id=(select id from auth.users where email='SIZNING@EMAIL');`
3. Qayta kiring: Profil > "Admin" tugmasi. Admin e'lonni yashiradi/o'chiradi, shikoyatlarni yopadi.

## Cheklovlar
- Bepul Supabase: 500 MB baza, 1 GB rasm, oyiga ~5 GB trafik; 1 hafta faolsizlikda project to'xtatilishi mumkin.
- Parol tiklash, email xabarnomalar, onlayn to'lov kiritilmagan.
