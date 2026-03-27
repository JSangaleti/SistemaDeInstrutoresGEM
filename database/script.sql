-- ** Database generated with pgModeler (PostgreSQL Database Modeler).
-- ** pgModeler version: 1.2.3
-- ** PostgreSQL version: 18.0
-- ** Project Site: pgmodeler.io
-- ** Model Author: ---

-- ** Database creation must be performed outside a multi lined SQL file. 
-- ** These commands were put in this file only as a convenience.

-- object: "Gem" | type: DATABASE --
-- DROP DATABASE IF EXISTS "Gem";
CREATE DATABASE "Gem"
	TABLESPACE = pg_default;
-- ddl-end --


SET search_path TO pg_catalog,public;
-- ddl-end --

-- object: public.aluno | type: TABLE --
-- DROP TABLE IF EXISTS public.aluno CASCADE;
CREATE TABLE public.aluno (
	id integer NOT NULL,
	id_instrumento integer,
	id_metodo integer,
	id_comum integer,
	nome text,
	CONSTRAINT aluno_pk PRIMARY KEY (id)
);
-- ddl-end --
ALTER TABLE public.aluno OWNER TO postgres;
-- ddl-end --

-- object: public.instrutor | type: TABLE --
-- DROP TABLE IF EXISTS public.instrutor CASCADE;
CREATE TABLE public.instrutor (
	cpf_pessoa varchar(11) NOT NULL,
	CONSTRAINT instrutor_pk PRIMARY KEY (cpf_pessoa)
);
-- ddl-end --
ALTER TABLE public.instrutor OWNER TO postgres;
-- ddl-end --

-- object: public.comum | type: TABLE --
-- DROP TABLE IF EXISTS public.comum CASCADE;
CREATE TABLE public.comum (
	id integer NOT NULL,
	sigla varchar(2),
	endereco text,
	nome text,
	CONSTRAINT comum_pk PRIMARY KEY (id)
);
-- ddl-end --
ALTER TABLE public.comum OWNER TO postgres;
-- ddl-end --

-- object: public.instrumento | type: TABLE --
-- DROP TABLE IF EXISTS public.instrumento CASCADE;
CREATE TABLE public.instrumento (
	id integer NOT NULL,
	nome text,
	CONSTRAINT instrumento_pk PRIMARY KEY (id)
);
-- ddl-end --
ALTER TABLE public.instrumento OWNER TO postgres;
-- ddl-end --

-- object: public.metodo | type: TABLE --
-- DROP TABLE IF EXISTS public.metodo CASCADE;
CREATE TABLE public.metodo (
	id integer NOT NULL,
	nome text,
	CONSTRAINT metodo_pk PRIMARY KEY (id)
);
-- ddl-end --
ALTER TABLE public.metodo OWNER TO postgres;
-- ddl-end --

-- object: public.admin | type: TABLE --
-- DROP TABLE IF EXISTS public.admin CASCADE;
CREATE TABLE public.admin (
	cpf_pessoa varchar(11) NOT NULL,
	CONSTRAINT admin_pk PRIMARY KEY (cpf_pessoa)
);
-- ddl-end --
ALTER TABLE public.admin OWNER TO postgres;
-- ddl-end --

-- object: public.aula | type: TABLE --
-- DROP TABLE IF EXISTS public.aula CASCADE;
CREATE TABLE public.aula (
	id integer NOT NULL,
	cpf_instrutor varchar(11),
	id_aluno integer,
	data date,
	descricao text,
	presenca bool,
	CONSTRAINT aula_pk PRIMARY KEY (id)
);
-- ddl-end --
ALTER TABLE public.aula OWNER TO postgres;
-- ddl-end --

-- object: public.estado | type: TABLE --
-- DROP TABLE IF EXISTS public.estado CASCADE;
CREATE TABLE public.estado (
	sigla varchar(2) NOT NULL,
	estado text,
	CONSTRAINT estado_pk PRIMARY KEY (sigla)
);
-- ddl-end --
ALTER TABLE public.estado OWNER TO postgres;
-- ddl-end --

-- object: public.pessoa | type: TABLE --
-- DROP TABLE IF EXISTS public.pessoa CASCADE;
CREATE TABLE public.pessoa (
	cpf varchar(11) NOT NULL,
	id_comum integer,
	nome text,
	usuario text,
	senha text,
	CONSTRAINT pessoa_pk PRIMARY KEY (cpf)
);
-- ddl-end --
ALTER TABLE public.pessoa OWNER TO postgres;
-- ddl-end --

-- object: id_comum | type: CONSTRAINT --
-- ALTER TABLE public.aluno DROP CONSTRAINT IF EXISTS id_comum CASCADE;
ALTER TABLE public.aluno ADD CONSTRAINT id_comum FOREIGN KEY (id_comum)
REFERENCES public.comum (id) MATCH SIMPLE
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: id_metodo | type: CONSTRAINT --
-- ALTER TABLE public.aluno DROP CONSTRAINT IF EXISTS id_metodo CASCADE;
ALTER TABLE public.aluno ADD CONSTRAINT id_metodo FOREIGN KEY (id_metodo)
REFERENCES public.metodo (id) MATCH SIMPLE
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: id_instrumento | type: CONSTRAINT --
-- ALTER TABLE public.aluno DROP CONSTRAINT IF EXISTS id_instrumento CASCADE;
ALTER TABLE public.aluno ADD CONSTRAINT id_instrumento FOREIGN KEY (id_instrumento)
REFERENCES public.instrumento (id) MATCH SIMPLE
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: cpf_pessoa | type: CONSTRAINT --
-- ALTER TABLE public.instrutor DROP CONSTRAINT IF EXISTS cpf_pessoa CASCADE;
ALTER TABLE public.instrutor ADD CONSTRAINT cpf_pessoa FOREIGN KEY (cpf_pessoa)
REFERENCES public.pessoa (cpf) MATCH SIMPLE
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: sigla | type: CONSTRAINT --
-- ALTER TABLE public.comum DROP CONSTRAINT IF EXISTS sigla CASCADE;
ALTER TABLE public.comum ADD CONSTRAINT sigla FOREIGN KEY (sigla)
REFERENCES public.estado (sigla) MATCH SIMPLE
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: cpf_pessoa | type: CONSTRAINT --
-- ALTER TABLE public.admin DROP CONSTRAINT IF EXISTS cpf_pessoa CASCADE;
ALTER TABLE public.admin ADD CONSTRAINT cpf_pessoa FOREIGN KEY (cpf_pessoa)
REFERENCES public.pessoa (cpf) MATCH SIMPLE
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: cpf_instrutor | type: CONSTRAINT --
-- ALTER TABLE public.aula DROP CONSTRAINT IF EXISTS cpf_instrutor CASCADE;
ALTER TABLE public.aula ADD CONSTRAINT cpf_instrutor FOREIGN KEY (cpf_instrutor)
REFERENCES public.instrutor (cpf_pessoa) MATCH SIMPLE
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: id_aluno | type: CONSTRAINT --
-- ALTER TABLE public.aula DROP CONSTRAINT IF EXISTS id_aluno CASCADE;
ALTER TABLE public.aula ADD CONSTRAINT id_aluno FOREIGN KEY (id_aluno)
REFERENCES public.aluno (id) MATCH SIMPLE
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: id_comum | type: CONSTRAINT --
-- ALTER TABLE public.pessoa DROP CONSTRAINT IF EXISTS id_comum CASCADE;
ALTER TABLE public.pessoa ADD CONSTRAINT id_comum FOREIGN KEY (id_comum)
REFERENCES public.comum (id) MATCH SIMPLE
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --


