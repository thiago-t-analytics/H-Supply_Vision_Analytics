--
-- PostgreSQL database dump
--

\restrict CG7XBoIf0AjFJfez7mBczVqF3KzmXibmTfbIcLSuhJcFzK8hL2zAUpwf7gWadkb

-- Dumped from database version 17.10
-- Dumped by pg_dump version 17.10

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: gold; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA gold;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: dim_cid; Type: TABLE; Schema: gold; Owner: -
--

CREATE TABLE gold.dim_cid (
    sk_cid integer NOT NULL,
    cid character varying(20) NOT NULL,
    descricao text,
    capitulo character varying(60),
    permanencia_media numeric(10,2),
    valor_medio numeric(14,2)
);


--
-- Name: dim_geo; Type: TABLE; Schema: gold; Owner: -
--

CREATE TABLE gold.dim_geo (
    sk_geo integer NOT NULL,
    municipio character varying(120) NOT NULL,
    regional character varying(60),
    macro character varying(60)
);


--
-- Name: dim_item; Type: TABLE; Schema: gold; Owner: -
--

CREATE TABLE gold.dim_item (
    sk_item integer NOT NULL,
    codigo_item character varying(50) NOT NULL,
    descritivo text,
    classificacao character varying(120),
    grupo_terapeutico character varying(120),
    tipo character varying(20)
);


--
-- Name: dim_item_analise; Type: TABLE; Schema: gold; Owner: -
--

CREATE TABLE gold.dim_item_analise (
    id_analise bigint NOT NULL,
    sk_item integer NOT NULL,
    codigo_item character varying(50) NOT NULL,
    descritivo text,
    grupo_terapeutico character varying(120),
    data_carga date NOT NULL,
    valido_de date NOT NULL,
    valido_ate date,
    consumo_90d numeric(14,3),
    consumo_medio_diario numeric(14,4),
    consumo_365d_estimado numeric(14,3),
    estoque_total numeric(14,3),
    valor_estoque_total numeric(14,2),
    qtd_lotes_ativos integer,
    dias_ate_vencer_mais_proximo integer,
    dias_ate_vencer_mais_distante integer,
    cobertura_dias integer,
    status_decisao character varying(20),
    indice_gravidade smallint,
    motivo_decisao text,
    primeiro_que_vence_sai boolean,
    tem_lote_parado boolean,
    locais_com_multiplos_lotes text,
    atualizado_em timestamp with time zone DEFAULT now()
);


--
-- Name: dim_item_analise_id_analise_seq; Type: SEQUENCE; Schema: gold; Owner: -
--

CREATE SEQUENCE gold.dim_item_analise_id_analise_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: dim_item_analise_id_analise_seq; Type: SEQUENCE OWNED BY; Schema: gold; Owner: -
--

ALTER SEQUENCE gold.dim_item_analise_id_analise_seq OWNED BY gold.dim_item_analise.id_analise;


--
-- Name: dim_paciente; Type: TABLE; Schema: gold; Owner: -
--

CREATE TABLE gold.dim_paciente (
    sk_paciente integer NOT NULL,
    prontuario character varying(200) NOT NULL,
    municipio character varying(120),
    regional_saude character varying(60),
    macro_saude character varying(60),
    primeira_internacao date,
    ultima_alta date,
    total_internacoes integer DEFAULT 0
);


--
-- Name: dim_procedimento; Type: TABLE; Schema: gold; Owner: -
--

CREATE TABLE gold.dim_procedimento (
    sk_procedimento integer NOT NULL,
    codigo_procedimento character varying(30) NOT NULL,
    nome_procedimento text,
    complexidade character varying(60),
    valor_sigtap numeric(14,2),
    servico_hospitalar numeric(14,2),
    servico_profissional numeric(14,2)
);


--
-- Name: dim_setor; Type: TABLE; Schema: gold; Owner: -
--

CREATE TABLE gold.dim_setor (
    sk_setor integer NOT NULL,
    nome character varying(120) NOT NULL,
    grupo character varying(60),
    tipo character varying(20)
);


--
-- Name: dim_tempo; Type: TABLE; Schema: gold; Owner: -
--

CREATE TABLE gold.dim_tempo (
    sk_tempo integer NOT NULL,
    data date NOT NULL,
    ano smallint NOT NULL,
    mes smallint NOT NULL,
    dia smallint NOT NULL,
    ano_mes integer NOT NULL,
    trimestre smallint NOT NULL,
    semana_iso smallint NOT NULL,
    dia_semana smallint NOT NULL,
    nome_dia_semana character varying(15) NOT NULL,
    nome_mes character varying(15) NOT NULL,
    eh_fim_semana boolean NOT NULL,
    faixa_validade character varying(20),
    ano_mes_texto character varying(10),
    mes_ano_abrev character varying(12),
    ano_mes_label character varying(10)
);


--
-- Name: dim_tempo_validade; Type: TABLE; Schema: gold; Owner: -
--

CREATE TABLE gold.dim_tempo_validade (
    sk_tempo integer NOT NULL,
    data date,
    ano smallint,
    mes smallint,
    dia smallint,
    ano_mes integer,
    trimestre smallint,
    semana_iso smallint,
    dia_semana smallint,
    nome_dia_semana character varying(15),
    nome_mes character varying(15),
    eh_fim_semana boolean,
    faixa_validade character varying(20),
    ano_mes_label character varying(10)
);


--
-- Name: fato_dispensacao; Type: TABLE; Schema: gold; Owner: -
--

CREATE TABLE gold.fato_dispensacao (
    id_dispensacao uuid NOT NULL,
    sk_tempo integer NOT NULL,
    sk_paciente integer NOT NULL,
    sk_item integer NOT NULL,
    sk_setor_origem integer NOT NULL,
    sk_setor_destino integer NOT NULL,
    sk_geo integer NOT NULL,
    qtde numeric(12,3) NOT NULL,
    valor_unitario numeric(12,4) NOT NULL,
    valor_total numeric(14,2) NOT NULL,
    forma_dispensacao character varying(50)
);


--
-- Name: fato_estoque_snapshot; Type: TABLE; Schema: gold; Owner: -
--

CREATE TABLE gold.fato_estoque_snapshot (
    id_snapshot bigint NOT NULL,
    sk_tempo_validade integer NOT NULL,
    sk_item integer NOT NULL,
    lote character varying(80),
    local_armazenado character varying(120),
    saldo_estoque numeric(14,3),
    valor_unitario numeric(12,4),
    valor_total numeric(14,2),
    sk_tempo_snapshot integer
);


--
-- Name: fato_estoque_snapshot_id_snapshot_seq; Type: SEQUENCE; Schema: gold; Owner: -
--

CREATE SEQUENCE gold.fato_estoque_snapshot_id_snapshot_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: fato_estoque_snapshot_id_snapshot_seq; Type: SEQUENCE OWNED BY; Schema: gold; Owner: -
--

ALTER SEQUENCE gold.fato_estoque_snapshot_id_snapshot_seq OWNED BY gold.fato_estoque_snapshot.id_snapshot;


--
-- Name: fato_internacao; Type: TABLE; Schema: gold; Owner: -
--

CREATE TABLE gold.fato_internacao (
    id_unico_evento character varying(120) NOT NULL,
    sk_tempo_intern integer NOT NULL,
    sk_tempo_alta integer NOT NULL,
    sk_paciente integer NOT NULL,
    sk_setor integer NOT NULL,
    sk_cid integer NOT NULL,
    sk_procedimento integer NOT NULL,
    sk_geo integer NOT NULL,
    permanencia_dias numeric(10,2),
    valor_sigtap numeric(14,2),
    cirurgia_realizada boolean
);


--
-- Name: fato_inventario; Type: TABLE; Schema: gold; Owner: -
--

CREATE TABLE gold.fato_inventario (
    id_registro bigint NOT NULL,
    sk_tempo integer NOT NULL,
    sk_item integer NOT NULL,
    lote character varying(80),
    local_armazenado character varying(120),
    saldo_sistema numeric(14,3),
    saldo_fisico numeric(14,3),
    divergencia numeric(14,3),
    valor_unitario numeric(12,4),
    valor_divergencia numeric(14,2),
    carregado_em timestamp with time zone DEFAULT now()
);


--
-- Name: fato_inventario_id_registro_seq; Type: SEQUENCE; Schema: gold; Owner: -
--

CREATE SEQUENCE gold.fato_inventario_id_registro_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: fato_inventario_id_registro_seq; Type: SEQUENCE OWNED BY; Schema: gold; Owner: -
--

ALTER SEQUENCE gold.fato_inventario_id_registro_seq OWNED BY gold.fato_inventario.id_registro;


--
-- Name: fifo_detalhe_atual; Type: TABLE; Schema: gold; Owner: -
--

CREATE TABLE gold.fifo_detalhe_atual (
    id_violacao bigint NOT NULL,
    data_carga date NOT NULL,
    tipo_violacao character varying(30) NOT NULL,
    gravidade smallint NOT NULL,
    sk_item integer,
    codigo_item character varying(50),
    descritivo text,
    grupo_terapeutico character varying(120),
    lote_dispensado character varying(80),
    validade_dispensado date,
    lote_ideal character varying(80),
    validade_ideal date,
    local_ideal character varying(120),
    diferenca_dias integer,
    local_armazenado character varying(120),
    setor_destino character varying(120),
    data_dispensacao date,
    prontuario character varying(200),
    descricao text,
    acao_sugerida text,
    carregado_em timestamp with time zone DEFAULT now()
);


--
-- Name: fifo_detalhe_atual_id_violacao_seq; Type: SEQUENCE; Schema: gold; Owner: -
--

CREATE SEQUENCE gold.fifo_detalhe_atual_id_violacao_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: fifo_detalhe_atual_id_violacao_seq; Type: SEQUENCE OWNED BY; Schema: gold; Owner: -
--

ALTER SEQUENCE gold.fifo_detalhe_atual_id_violacao_seq OWNED BY gold.fifo_detalhe_atual.id_violacao;


--
-- Name: fifo_furo_estoque; Type: TABLE; Schema: gold; Owner: -
--

CREATE TABLE gold.fifo_furo_estoque (
    id_furo bigint NOT NULL,
    data_carga date NOT NULL,
    sk_item integer,
    codigo_item character varying(50),
    descritivo text,
    lote_parado character varying(80),
    validade_parado date,
    saldo_parado numeric(14,3),
    local_parado character varying(120),
    dias_ate_vencer integer,
    lote_consumido character varying(80),
    validade_consumido date,
    ultima_dispensacao date,
    gravidade smallint,
    descricao text,
    acao_sugerida text,
    carregado_em timestamp with time zone DEFAULT now()
);


--
-- Name: fifo_furo_estoque_id_furo_seq; Type: SEQUENCE; Schema: gold; Owner: -
--

CREATE SEQUENCE gold.fifo_furo_estoque_id_furo_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: fifo_furo_estoque_id_furo_seq; Type: SEQUENCE OWNED BY; Schema: gold; Owner: -
--

ALTER SEQUENCE gold.fifo_furo_estoque_id_furo_seq OWNED BY gold.fifo_furo_estoque.id_furo;


--
-- Name: fifo_recorrente; Type: TABLE; Schema: gold; Owner: -
--

CREATE TABLE gold.fifo_recorrente (
    id_recorrencia bigint NOT NULL,
    chave_violacao character varying(200) NOT NULL,
    sk_item integer,
    codigo_item character varying(50),
    descritivo text,
    lote character varying(80),
    tipo_violacao character varying(30),
    local_armazenado character varying(120),
    primeira_ocorrencia date,
    ultima_ocorrencia date,
    semanas_consecutivas integer DEFAULT 1,
    total_ocorrencias integer DEFAULT 1,
    status character varying(20) DEFAULT 'ATIVO'::character varying,
    atualizado_em timestamp with time zone DEFAULT now()
);


--
-- Name: fifo_recorrente_id_recorrencia_seq; Type: SEQUENCE; Schema: gold; Owner: -
--

CREATE SEQUENCE gold.fifo_recorrente_id_recorrencia_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: fifo_recorrente_id_recorrencia_seq; Type: SEQUENCE OWNED BY; Schema: gold; Owner: -
--

ALTER SEQUENCE gold.fifo_recorrente_id_recorrencia_seq OWNED BY gold.fifo_recorrente.id_recorrencia;


--
-- Name: fifo_resumo_semanal; Type: TABLE; Schema: gold; Owner: -
--

CREATE TABLE gold.fifo_resumo_semanal (
    id_resumo bigint NOT NULL,
    semana_inicio date NOT NULL,
    semana_fim date NOT NULL,
    tipo_violacao character varying(30) NOT NULL,
    gravidade smallint NOT NULL,
    qtd_violacoes integer NOT NULL,
    qtd_itens_distintos integer,
    valor_total_envolvido numeric(14,2),
    carregado_em timestamp with time zone DEFAULT now()
);


--
-- Name: fifo_resumo_semanal_id_resumo_seq; Type: SEQUENCE; Schema: gold; Owner: -
--

CREATE SEQUENCE gold.fifo_resumo_semanal_id_resumo_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: fifo_resumo_semanal_id_resumo_seq; Type: SEQUENCE OWNED BY; Schema: gold; Owner: -
--

ALTER SEQUENCE gold.fifo_resumo_semanal_id_resumo_seq OWNED BY gold.fifo_resumo_semanal.id_resumo;


--
-- Name: dim_item_analise id_analise; Type: DEFAULT; Schema: gold; Owner: -
--

ALTER TABLE ONLY gold.dim_item_analise ALTER COLUMN id_analise SET DEFAULT nextval('gold.dim_item_analise_id_analise_seq'::regclass);


--
-- Name: fato_estoque_snapshot id_snapshot; Type: DEFAULT; Schema: gold; Owner: -
--

ALTER TABLE ONLY gold.fato_estoque_snapshot ALTER COLUMN id_snapshot SET DEFAULT nextval('gold.fato_estoque_snapshot_id_snapshot_seq'::regclass);


--
-- Name: fato_inventario id_registro; Type: DEFAULT; Schema: gold; Owner: -
--

ALTER TABLE ONLY gold.fato_inventario ALTER COLUMN id_registro SET DEFAULT nextval('gold.fato_inventario_id_registro_seq'::regclass);


--
-- Name: fifo_detalhe_atual id_violacao; Type: DEFAULT; Schema: gold; Owner: -
--

ALTER TABLE ONLY gold.fifo_detalhe_atual ALTER COLUMN id_violacao SET DEFAULT nextval('gold.fifo_detalhe_atual_id_violacao_seq'::regclass);


--
-- Name: fifo_furo_estoque id_furo; Type: DEFAULT; Schema: gold; Owner: -
--

ALTER TABLE ONLY gold.fifo_furo_estoque ALTER COLUMN id_furo SET DEFAULT nextval('gold.fifo_furo_estoque_id_furo_seq'::regclass);


--
-- Name: fifo_recorrente id_recorrencia; Type: DEFAULT; Schema: gold; Owner: -
--

ALTER TABLE ONLY gold.fifo_recorrente ALTER COLUMN id_recorrencia SET DEFAULT nextval('gold.fifo_recorrente_id_recorrencia_seq'::regclass);


--
-- Name: fifo_resumo_semanal id_resumo; Type: DEFAULT; Schema: gold; Owner: -
--

ALTER TABLE ONLY gold.fifo_resumo_semanal ALTER COLUMN id_resumo SET DEFAULT nextval('gold.fifo_resumo_semanal_id_resumo_seq'::regclass);


--
-- Name: dim_cid dim_cid_cid_key; Type: CONSTRAINT; Schema: gold; Owner: -
--

ALTER TABLE ONLY gold.dim_cid
    ADD CONSTRAINT dim_cid_cid_key UNIQUE (cid);


--
-- Name: dim_cid dim_cid_pkey; Type: CONSTRAINT; Schema: gold; Owner: -
--

ALTER TABLE ONLY gold.dim_cid
    ADD CONSTRAINT dim_cid_pkey PRIMARY KEY (sk_cid);


--
-- Name: dim_geo dim_geo_municipio_regional_macro_key; Type: CONSTRAINT; Schema: gold; Owner: -
--

ALTER TABLE ONLY gold.dim_geo
    ADD CONSTRAINT dim_geo_municipio_regional_macro_key UNIQUE (municipio, regional, macro);


--
-- Name: dim_geo dim_geo_pkey; Type: CONSTRAINT; Schema: gold; Owner: -
--

ALTER TABLE ONLY gold.dim_geo
    ADD CONSTRAINT dim_geo_pkey PRIMARY KEY (sk_geo);


--
-- Name: dim_item_analise dim_item_analise_pkey; Type: CONSTRAINT; Schema: gold; Owner: -
--

ALTER TABLE ONLY gold.dim_item_analise
    ADD CONSTRAINT dim_item_analise_pkey PRIMARY KEY (id_analise);


--
-- Name: dim_item_analise dim_item_analise_sk_item_data_carga_key; Type: CONSTRAINT; Schema: gold; Owner: -
--

ALTER TABLE ONLY gold.dim_item_analise
    ADD CONSTRAINT dim_item_analise_sk_item_data_carga_key UNIQUE (sk_item, data_carga);


--
-- Name: dim_item dim_item_codigo_item_key; Type: CONSTRAINT; Schema: gold; Owner: -
--

ALTER TABLE ONLY gold.dim_item
    ADD CONSTRAINT dim_item_codigo_item_key UNIQUE (codigo_item);


--
-- Name: dim_item dim_item_pkey; Type: CONSTRAINT; Schema: gold; Owner: -
--

ALTER TABLE ONLY gold.dim_item
    ADD CONSTRAINT dim_item_pkey PRIMARY KEY (sk_item);


--
-- Name: dim_paciente dim_paciente_pkey; Type: CONSTRAINT; Schema: gold; Owner: -
--

ALTER TABLE ONLY gold.dim_paciente
    ADD CONSTRAINT dim_paciente_pkey PRIMARY KEY (sk_paciente);


--
-- Name: dim_paciente dim_paciente_prontuario_key; Type: CONSTRAINT; Schema: gold; Owner: -
--

ALTER TABLE ONLY gold.dim_paciente
    ADD CONSTRAINT dim_paciente_prontuario_key UNIQUE (prontuario);


--
-- Name: dim_procedimento dim_procedimento_codigo_procedimento_key; Type: CONSTRAINT; Schema: gold; Owner: -
--

ALTER TABLE ONLY gold.dim_procedimento
    ADD CONSTRAINT dim_procedimento_codigo_procedimento_key UNIQUE (codigo_procedimento);


--
-- Name: dim_procedimento dim_procedimento_pkey; Type: CONSTRAINT; Schema: gold; Owner: -
--

ALTER TABLE ONLY gold.dim_procedimento
    ADD CONSTRAINT dim_procedimento_pkey PRIMARY KEY (sk_procedimento);


--
-- Name: dim_setor dim_setor_nome_key; Type: CONSTRAINT; Schema: gold; Owner: -
--

ALTER TABLE ONLY gold.dim_setor
    ADD CONSTRAINT dim_setor_nome_key UNIQUE (nome);


--
-- Name: dim_setor dim_setor_pkey; Type: CONSTRAINT; Schema: gold; Owner: -
--

ALTER TABLE ONLY gold.dim_setor
    ADD CONSTRAINT dim_setor_pkey PRIMARY KEY (sk_setor);


--
-- Name: dim_tempo dim_tempo_pkey; Type: CONSTRAINT; Schema: gold; Owner: -
--

ALTER TABLE ONLY gold.dim_tempo
    ADD CONSTRAINT dim_tempo_pkey PRIMARY KEY (sk_tempo);


--
-- Name: dim_tempo_validade dim_tempo_validade_pkey; Type: CONSTRAINT; Schema: gold; Owner: -
--

ALTER TABLE ONLY gold.dim_tempo_validade
    ADD CONSTRAINT dim_tempo_validade_pkey PRIMARY KEY (sk_tempo);


--
-- Name: fato_dispensacao fato_dispensacao_pkey; Type: CONSTRAINT; Schema: gold; Owner: -
--

ALTER TABLE ONLY gold.fato_dispensacao
    ADD CONSTRAINT fato_dispensacao_pkey PRIMARY KEY (id_dispensacao);


--
-- Name: fato_estoque_snapshot fato_estoque_snapshot_pkey; Type: CONSTRAINT; Schema: gold; Owner: -
--

ALTER TABLE ONLY gold.fato_estoque_snapshot
    ADD CONSTRAINT fato_estoque_snapshot_pkey PRIMARY KEY (id_snapshot);


--
-- Name: fato_internacao fato_internacao_pkey; Type: CONSTRAINT; Schema: gold; Owner: -
--

ALTER TABLE ONLY gold.fato_internacao
    ADD CONSTRAINT fato_internacao_pkey PRIMARY KEY (id_unico_evento);


--
-- Name: fato_inventario fato_inventario_pkey; Type: CONSTRAINT; Schema: gold; Owner: -
--

ALTER TABLE ONLY gold.fato_inventario
    ADD CONSTRAINT fato_inventario_pkey PRIMARY KEY (id_registro);


--
-- Name: fifo_detalhe_atual fifo_detalhe_atual_pkey; Type: CONSTRAINT; Schema: gold; Owner: -
--

ALTER TABLE ONLY gold.fifo_detalhe_atual
    ADD CONSTRAINT fifo_detalhe_atual_pkey PRIMARY KEY (id_violacao);


--
-- Name: fifo_furo_estoque fifo_furo_estoque_pkey; Type: CONSTRAINT; Schema: gold; Owner: -
--

ALTER TABLE ONLY gold.fifo_furo_estoque
    ADD CONSTRAINT fifo_furo_estoque_pkey PRIMARY KEY (id_furo);


--
-- Name: fifo_recorrente fifo_recorrente_chave_violacao_key; Type: CONSTRAINT; Schema: gold; Owner: -
--

ALTER TABLE ONLY gold.fifo_recorrente
    ADD CONSTRAINT fifo_recorrente_chave_violacao_key UNIQUE (chave_violacao);


--
-- Name: fifo_recorrente fifo_recorrente_pkey; Type: CONSTRAINT; Schema: gold; Owner: -
--

ALTER TABLE ONLY gold.fifo_recorrente
    ADD CONSTRAINT fifo_recorrente_pkey PRIMARY KEY (id_recorrencia);


--
-- Name: fifo_resumo_semanal fifo_resumo_semanal_pkey; Type: CONSTRAINT; Schema: gold; Owner: -
--

ALTER TABLE ONLY gold.fifo_resumo_semanal
    ADD CONSTRAINT fifo_resumo_semanal_pkey PRIMARY KEY (id_resumo);


--
-- Name: fifo_resumo_semanal fifo_resumo_semanal_semana_inicio_tipo_violacao_gravidade_key; Type: CONSTRAINT; Schema: gold; Owner: -
--

ALTER TABLE ONLY gold.fifo_resumo_semanal
    ADD CONSTRAINT fifo_resumo_semanal_semana_inicio_tipo_violacao_gravidade_key UNIQUE (semana_inicio, tipo_violacao, gravidade);


--
-- Name: ix_dim_cid_cid; Type: INDEX; Schema: gold; Owner: -
--

CREATE INDEX ix_dim_cid_cid ON gold.dim_cid USING btree (cid);


--
-- Name: ix_dim_item_analise_gravidade; Type: INDEX; Schema: gold; Owner: -
--

CREATE INDEX ix_dim_item_analise_gravidade ON gold.dim_item_analise USING btree (indice_gravidade);


--
-- Name: ix_dim_item_analise_item; Type: INDEX; Schema: gold; Owner: -
--

CREATE INDEX ix_dim_item_analise_item ON gold.dim_item_analise USING btree (sk_item);


--
-- Name: ix_dim_item_analise_status; Type: INDEX; Schema: gold; Owner: -
--

CREATE INDEX ix_dim_item_analise_status ON gold.dim_item_analise USING btree (status_decisao);


--
-- Name: ix_dim_item_analise_vigente; Type: INDEX; Schema: gold; Owner: -
--

CREATE INDEX ix_dim_item_analise_vigente ON gold.dim_item_analise USING btree (sk_item, valido_ate);


--
-- Name: ix_dim_item_classificacao; Type: INDEX; Schema: gold; Owner: -
--

CREATE INDEX ix_dim_item_classificacao ON gold.dim_item USING btree (classificacao);


--
-- Name: ix_dim_paciente_macro; Type: INDEX; Schema: gold; Owner: -
--

CREATE INDEX ix_dim_paciente_macro ON gold.dim_paciente USING btree (macro_saude);


--
-- Name: ix_dim_paciente_prontuario; Type: INDEX; Schema: gold; Owner: -
--

CREATE INDEX ix_dim_paciente_prontuario ON gold.dim_paciente USING btree (prontuario);


--
-- Name: ix_dim_procedimento_codigo; Type: INDEX; Schema: gold; Owner: -
--

CREATE INDEX ix_dim_procedimento_codigo ON gold.dim_procedimento USING btree (codigo_procedimento);


--
-- Name: ix_dim_tempo_ano_mes; Type: INDEX; Schema: gold; Owner: -
--

CREATE INDEX ix_dim_tempo_ano_mes ON gold.dim_tempo USING btree (ano_mes);


--
-- Name: ix_fato_disp_destino; Type: INDEX; Schema: gold; Owner: -
--

CREATE INDEX ix_fato_disp_destino ON gold.fato_dispensacao USING btree (sk_setor_destino);


--
-- Name: ix_fato_disp_item; Type: INDEX; Schema: gold; Owner: -
--

CREATE INDEX ix_fato_disp_item ON gold.fato_dispensacao USING btree (sk_item);


--
-- Name: ix_fato_disp_paciente; Type: INDEX; Schema: gold; Owner: -
--

CREATE INDEX ix_fato_disp_paciente ON gold.fato_dispensacao USING btree (sk_paciente);


--
-- Name: ix_fato_disp_tempo; Type: INDEX; Schema: gold; Owner: -
--

CREATE INDEX ix_fato_disp_tempo ON gold.fato_dispensacao USING btree (sk_tempo);


--
-- Name: ix_fato_estoque_item; Type: INDEX; Schema: gold; Owner: -
--

CREATE INDEX ix_fato_estoque_item ON gold.fato_estoque_snapshot USING btree (sk_item);


--
-- Name: ix_fato_estoque_tempo_snapshot; Type: INDEX; Schema: gold; Owner: -
--

CREATE INDEX ix_fato_estoque_tempo_snapshot ON gold.fato_estoque_snapshot USING btree (sk_tempo_snapshot);


--
-- Name: ix_fato_estoque_validade; Type: INDEX; Schema: gold; Owner: -
--

CREATE INDEX ix_fato_estoque_validade ON gold.fato_estoque_snapshot USING btree (sk_tempo_validade);


--
-- Name: ix_fato_int_cid; Type: INDEX; Schema: gold; Owner: -
--

CREATE INDEX ix_fato_int_cid ON gold.fato_internacao USING btree (sk_cid);


--
-- Name: ix_fato_int_paciente; Type: INDEX; Schema: gold; Owner: -
--

CREATE INDEX ix_fato_int_paciente ON gold.fato_internacao USING btree (sk_paciente);


--
-- Name: ix_fato_int_proced; Type: INDEX; Schema: gold; Owner: -
--

CREATE INDEX ix_fato_int_proced ON gold.fato_internacao USING btree (sk_procedimento);


--
-- Name: ix_fato_int_tempo_intern; Type: INDEX; Schema: gold; Owner: -
--

CREATE INDEX ix_fato_int_tempo_intern ON gold.fato_internacao USING btree (sk_tempo_intern);


--
-- Name: ix_fato_inventario_item; Type: INDEX; Schema: gold; Owner: -
--

CREATE INDEX ix_fato_inventario_item ON gold.fato_inventario USING btree (sk_item);


--
-- Name: ix_fato_inventario_tempo; Type: INDEX; Schema: gold; Owner: -
--

CREATE INDEX ix_fato_inventario_tempo ON gold.fato_inventario USING btree (sk_tempo);


--
-- Name: ix_fifo_det_grav; Type: INDEX; Schema: gold; Owner: -
--

CREATE INDEX ix_fifo_det_grav ON gold.fifo_detalhe_atual USING btree (gravidade);


--
-- Name: ix_fifo_det_item; Type: INDEX; Schema: gold; Owner: -
--

CREATE INDEX ix_fifo_det_item ON gold.fifo_detalhe_atual USING btree (sk_item);


--
-- Name: ix_fifo_det_local; Type: INDEX; Schema: gold; Owner: -
--

CREATE INDEX ix_fifo_det_local ON gold.fifo_detalhe_atual USING btree (local_armazenado);


--
-- Name: ix_fifo_det_tipo; Type: INDEX; Schema: gold; Owner: -
--

CREATE INDEX ix_fifo_det_tipo ON gold.fifo_detalhe_atual USING btree (tipo_violacao);


--
-- Name: ix_fifo_furo_item; Type: INDEX; Schema: gold; Owner: -
--

CREATE INDEX ix_fifo_furo_item ON gold.fifo_furo_estoque USING btree (sk_item);


--
-- Name: ix_fifo_rec_item; Type: INDEX; Schema: gold; Owner: -
--

CREATE INDEX ix_fifo_rec_item ON gold.fifo_recorrente USING btree (sk_item);


--
-- Name: ix_fifo_rec_status; Type: INDEX; Schema: gold; Owner: -
--

CREATE INDEX ix_fifo_rec_status ON gold.fifo_recorrente USING btree (status);


--
-- Name: ix_fifo_res_semana; Type: INDEX; Schema: gold; Owner: -
--

CREATE INDEX ix_fifo_res_semana ON gold.fifo_resumo_semanal USING btree (semana_inicio);


--
-- PostgreSQL database dump complete
--

\unrestrict CG7XBoIf0AjFJfez7mBczVqF3KzmXibmTfbIcLSuhJcFzK8hL2zAUpwf7gWadkb

