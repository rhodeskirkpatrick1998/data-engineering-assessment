-- Create schemas
create schema if not exists raw;
create schema if not exists staging;
create schema if not exists marts;

-- Create roles
do $$
begin
    if not exists (select 1 from pg_roles where rolname = 'bf_developer') then
        create role bf_developer;
    end if;

    if not exists (select 1 from pg_roles where rolname = 'bf_airbyte') then
        create role bf_airbyte;
    end if;

    if not exists (select 1 from pg_roles where rolname = 'bf_dbt') then
        create role bf_dbt;
    end if;

    if not exists (select 1 from pg_roles where rolname = 'bf_bi') then
        create role bf_bi;
    end if;
end $$;

-- Remove broad public defaults
revoke all on schema raw from public;
revoke all on schema staging from public;
revoke all on schema marts from public;

-- Developer
grant usage on schema raw to bf_developer;
grant select on all tables in schema raw to bf_developer;

grant usage, create on schema staging to bf_developer;
grant select, insert, update, delete on all tables in schema staging to bf_developer;

grant usage on schema marts to bf_developer;
grant select on all tables in schema marts to bf_developer;

-- Airbyte ingestion role
grant usage, create on schema raw to bf_airbyte;
grant select, insert, update, delete on all tables in schema raw to bf_airbyte;

-- dbt transformation role
grant usage on schema raw to bf_dbt;
grant select on all tables in schema raw to bf_dbt;

grant usage, create on schema staging to bf_dbt;
grant select, insert, update, delete on all tables in schema staging to bf_dbt;

grant usage, create on schema marts to bf_dbt;
grant select, insert, update, delete on all tables in schema marts to bf_dbt;

-- BI read-only role
grant usage on schema marts to bf_bi;
grant select on all tables in schema marts to bf_bi;

-- Default privileges for future tables created by current user
alter default privileges in schema raw
grant select on tables to bf_developer, bf_dbt;

alter default privileges in schema raw
grant select, insert, update, delete on tables to bf_airbyte;

alter default privileges in schema staging
grant select, insert, update, delete on tables to bf_developer, bf_dbt;

alter default privileges in schema marts
grant select on tables to bf_developer, bf_bi;

alter default privileges in schema marts
grant select, insert, update, delete on tables to bf_dbt;