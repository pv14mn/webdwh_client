set app.WEBDWH_PASSWORD to :'WEBDWH_PASSWORD';
set app.VIEWER_PASSWORD to :'VIEWER_PASSWORD';

do
$$
begin
  if not exists (select 1 from pg_user where usename = 'webdwh') then
     execute format('create user webdwh password %L', current_setting('app.WEBDWH_PASSWORD', false));
  end if;
  if not exists (select 1 from pg_user where usename = 'viewer') then
     execute format('create user viewer password %L', current_setting('app.VIEWER_PASSWORD', false));
     -- grant pg_read_all_data to viewer;
     create schema if not exists viewer authorization viewer;
  end if;
end
$$
;
