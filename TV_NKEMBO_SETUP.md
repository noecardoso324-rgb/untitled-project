# TV Nkembo — configurar o painel de administrador

## Preparado no GitHub
- `admin.html`: login Supabase e gestão de conteúdos (criar, editar, publicar/guardar rascunho, eliminar).
- `supabase-config.js`: modelo para URL e chave pública do Supabase.
- `supabase/schema.sql`: tabelas e políticas RLS para limitar gestão a administradores.
- O botão Admin na página inicial abre `admin.html`.

## Passo 1 — criar a base de dados
1. Cria um projecto em https://supabase.com.
2. Abre SQL Editor no projecto.
3. Abre `supabase/schema.sql` neste repositório, copia todo o conteúdo e executa-o.

## Passo 2 — ligar o site ao Supabase
1. No Supabase, abre Project Settings → API (ou Connect).
2. Copia a Project URL e a chave pública anon/publishable.
3. Edita `supabase-config.js` no GitHub e substitui os dois valores `COLOCA_AQUI...`.
4. Nunca uses a chave `service_role` no navegador, no GitHub ou em mensagens.

## Passo 3 — criar a conta administradora
1. No Supabase, abre Authentication → Users e cria/adiciona uma conta com o teu e-mail.
2. Copia o UUID dessa conta.
3. No SQL Editor, executa o comando abaixo com os teus valores:
```sql
insert into public.profiles (id, email, role)
values ('UUID_DO_UTILIZADOR', 'TEU_EMAIL', 'admin')
on conflict (id) do update set email = excluded.email, role = 'admin';
```
4. Entra em `admin.html` com essa conta. A conta precisa de existir em Authentication antes de receber o papel admin.

## Passo 4 — publicar
Activa GitHub Pages em Settings → Pages e escolhe GitHub Actions; depois confirma que o workflow termina sem erros em Actions. O site tem de estar servido por HTTPS.

## Limitações desta etapa
- O painel já está preparado para guardar metadados no Supabase, mas só funciona depois de configurares URL, chave e conta admin.
- O link de reprodução é apenas um campo de catálogo: player protegido, uploads de ficheiros, gestão de clientes, pagamentos e assinaturas são etapas seguintes.
- Distribui apenas conteúdos próprios ou licenciados.
