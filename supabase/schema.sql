-- TV Nkembo: schema inicial para Supabase
-- Executa no SQL Editor do projecto. RLS permite ao público ler apenas conteúdos publicados.

create extension if not exists pgcrypto;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  email text,
  role text not null default 'customer' check (role in ('customer','admin')),
  created_at timestamptz not null default now()
);

create table if not exists public.contents (
  id uuid primary key default gen_random_uuid(),
  title text not null check (char_length(title) between 1 and 100),
  category text not null check (category in ('Filmes','Séries','Desporto','Novelas','Animes','Conteúdo próprio','TV ao vivo autorizada')),
  description text not null default '',
  cover_url text,
  playback_url text,
  content_type text not null default 'video' check (content_type in ('video','live','external')),
  is_published boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists contents_published_created_idx on public.contents (is_published, created_at desc);

create or replace function public.is_nkembo_admin()
returns boolean language sql stable security definer set search_path = ''
as $$
  select exists (select 1 from public.profiles p where p.id = (select auth.uid()) and p.role = 'admin');
$$;

revoke all on function public.is_nkembo_admin() from public;
grant execute on function public.is_nkembo_admin() to anon, authenticated;

alter table public.profiles enable row level security;
alter table public.contents enable row level security;

drop policy if exists "profile can read own record" on public.profiles;
create policy "profile can read own record" on public.profiles for select to authenticated
using (id = (select auth.uid()) or public.is_nkembo_admin());

drop policy if exists "admins can manage profiles" on public.profiles;
create policy "admins can manage profiles" on public.profiles for all to authenticated
using (public.is_nkembo_admin()) with check (public.is_nkembo_admin());

drop policy if exists "public can read published contents" on public.contents;
create policy "public can read published contents" on public.contents for select to anon, authenticated
using (is_published = true or public.is_nkembo_admin());

drop policy if exists "admins can insert contents" on public.contents;
create policy "admins can insert contents" on public.contents for insert to authenticated
with check (public.is_nkembo_admin());

drop policy if exists "admins can update contents" on public.contents;
create policy "admins can update contents" on public.contents for update to authenticated
using (public.is_nkembo_admin()) with check (public.is_nkembo_admin());

drop policy if exists "admins can delete contents" on public.contents;
create policy "admins can delete contents" on public.contents for delete to authenticated
using (public.is_nkembo_admin());

-- Cria primeiro o utilizador em Authentication > Users e depois atribui o papel admin:
-- insert into public.profiles (id, email, role)
-- values ('UUID_DO_UTILIZADOR', 'TEU_EMAIL', 'admin')
-- on conflict (id) do update set email = excluded.email, role = 'admin';

create or replace function public.handle_new_user()
returns trigger language plpgsql security definer set search_path = ''
as $$
begin
  insert into public.profiles (id, email, role) values (new.id, new.email, 'customer')
  on conflict (id) do update set email = excluded.email;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created after insert on auth.users
for each row execute procedure public.handle_new_user();
