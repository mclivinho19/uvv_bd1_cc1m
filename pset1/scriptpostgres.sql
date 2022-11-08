-- Criação de usuário e banco de dados.
psql -U postgres
computacao@raiz

CREATE USER guilherme WITH PASSWORD '202203272';
ALTER USER guilherme WITH SUPERUSER;

CREATE DATABASE uvv
    WITH 
    OWNER = guilherme
    TEMPLATE = template0
    ENCODING = 'UTF8'
    LC_COLLATE = 'pt_BR.UTF-8'
    LC_CTYPE = 'pt_BR.UTF-8'
    ALLOW_CONNECTIONS = true;

GRANT TEMPORARY, CONNECT ON DATABASE uvv TO PUBLIC;

GRANT ALL ON DATABASE uvv TO guilherme;

ALTER DEFAULT PRIVILEGES
GRANT ALL ON TABLES TO guilherme;

exit
-- Fazendo login denovo.
psql -U guilherme uvv
202203272

-- Criação dos schemas.
CREATE SCHEMA hr
AUTHORIZATION guilherme;

SHOW SEARCH_PATH;
SELECT CURRENT_SCHEMA();
SET SEARCH_PATH TO hr, "\$user", public;
ALTER USER guilherme SET SEARCH_PATH TO hr, "\$user", public;

-- Criação das tabelas e relações

CREATE TABLE cargos (
                id_cargo VARCHAR(10) NOT NULL,
                cargo VARCHAR(35) NOT NULL,
                salario_minimo NUMERIC(8,2),
                salario_maximo NUMERIC(8,2),
                CONSTRAINT id_cargo PRIMARY KEY (id_cargo)
);
COMMENT ON TABLE cargos IS 'Tabela cargos, que armazena os cargos existentes e a faixa salarial (mínimo
e máximo) para cada cargo.';
COMMENT ON COLUMN cargos.id_cargo IS 'Chave primária da tabela.';
COMMENT ON COLUMN cargos.cargo IS 'Nome do cargo.';
COMMENT ON COLUMN cargos.salario_minimo IS 'O menor salário admitido para um cargo.';
COMMENT ON COLUMN cargos.salario_maximo IS 'O maior salário admitido para um cargo.';


CREATE UNIQUE INDEX cargos_idx
 ON cargos
 ( cargo );

CREATE TABLE regioes (
                id_regiao INTEGER NOT NULL,
                nome VARCHAR(25) NOT NULL,
                CONSTRAINT id_regiao PRIMARY KEY (id_regiao)
);
COMMENT ON TABLE regioes IS 'Tabela regiões. Contém os números e nomes das regiões.';
COMMENT ON COLUMN regioes.id_regiao IS 'Chave primária da tabela regiões.';
COMMENT ON COLUMN regioes.nome IS 'Nomes das regiões.';


CREATE UNIQUE INDEX regioes_idx
 ON regioes
 ( nome );

CREATE TABLE paises (
                id_pais CHAR(2) NOT NULL,
                nome VARCHAR(50) NOT NULL,
                id_regiao INTEGER NOT NULL,
                CONSTRAINT id_pais PRIMARY KEY (id_pais)
);
COMMENT ON TABLE paises IS 'Tabela com as informaçõs dos países.';
COMMENT ON COLUMN paises.id_pais IS 'Chave primária da tabela países.';
COMMENT ON COLUMN paises.nome IS 'Nome do país.';
COMMENT ON COLUMN paises.id_regiao IS 'Chave estrangeira para a tabela de regiões.';


CREATE UNIQUE INDEX paises_idx
 ON paises
 ( nome );

CREATE TABLE localizacoes (
                id_localizacao INTEGER NOT NULL,
                endereco VARCHAR(50),
                cep VARCHAR(12),
                cidade VARCHAR(50),
                uf VARCHAR(25),
                id_pais CHAR(2) NOT NULL,
                CONSTRAINT id_localizacao PRIMARY KEY (id_localizacao)
);
COMMENT ON TABLE localizacoes IS 'Contém os endereços de diversos escritórios e facilidades
da empresa.';
COMMENT ON COLUMN localizacoes.id_localizacao IS 'Chave primária da tabela.';
COMMENT ON COLUMN localizacoes.endereco IS 'Endereço de um escritório ou facilidade da empresa.';
COMMENT ON COLUMN localizacoes.cep IS 'CEP - localizacao';
COMMENT ON COLUMN localizacoes.cidade IS 'Cidade da empresa.';
COMMENT ON COLUMN localizacoes.uf IS 'Estado da empresa.';
COMMENT ON COLUMN localizacoes.id_pais IS 'Chave estrangeira para a tabela de países.';


CREATE TABLE departamentos (
                id_departamento INTEGER NOT NULL,
                nome VARCHAR(50),
                id_localizacao INTEGER NOT NULL,
                id_gerente INTEGER NOT NULL,
                CONSTRAINT id_departamento PRIMARY KEY (id_departamento)
);
COMMENT ON TABLE departamentos IS 'Tabela com as informações sobre os departamentos da empresa.';
COMMENT ON COLUMN departamentos.id_departamento IS 'Chave primária da tabela.';
COMMENT ON COLUMN departamentos.nome IS 'Nome do departamento da tabela.';
COMMENT ON COLUMN departamentos.id_localizacao IS 'qual empregado,
se houver, é o gerente deste departamento.';
COMMENT ON COLUMN departamentos.id_gerente IS 'Chave primária da tabela.';


CREATE UNIQUE INDEX departamentos_idx
 ON departamentos
 ( nome );

CREATE TABLE empregados (
                id_empregado INTEGER NOT NULL,
                nome VARCHAR(75) NOT NULL,
                email VARCHAR(35) NOT NULL,
                telefone VARCHAR(20),
                data_contratacao DATE NOT NULL,
                id_cargo VARCHAR(10) NOT NULL,
                salario NUMERIC(8,2),
                comissao NUMERIC(4,2),
                id_departamento INTEGER NOT NULL,
                id_supervisor INTEGER NOT NULL,
                CONSTRAINT id_empregado PRIMARY KEY (id_empregado)
);
COMMENT ON TABLE empregados IS 'Tabela que contém as informações dos empregados.';
COMMENT ON COLUMN empregados.id_empregado IS 'Chave primária da tabela.';
COMMENT ON COLUMN empregados.nome IS 'Nome completo do empregado.';
COMMENT ON COLUMN empregados.email IS 'Parte inicial do email do empregado (antes do @).';
COMMENT ON COLUMN empregados.telefone IS 'ado).';
COMMENT ON COLUMN empregados.data_contratacao IS 'Data que o empregado iniciou no cargo atual.';
COMMENT ON COLUMN empregados.id_cargo IS 'do empregado.';
COMMENT ON COLUMN empregados.salario IS 'Salário mensal atual do empregado.';
COMMENT ON COLUMN empregados.comissao IS 'o departamento
de vendas são elegíveis para comissões.';
COMMENT ON COLUMN empregados.id_departamento IS 'epartamento atual
de um empregado.';
COMMENT ON COLUMN empregados.id_supervisor IS 'Chave primária da tabela.';


CREATE UNIQUE INDEX empregados_idx
 ON empregados
 ( email );

CREATE TABLE historico_cargos (
                data_final DATE NOT NULL,
                id_empregado INTEGER NOT NULL,
                data_final_1 DATE NOT NULL,
                id_cargo VARCHAR(10) NOT NULL,
                id_departamento INTEGER NOT NULL,
                CONSTRAINT data_inicial PRIMARY KEY (data_final, id_empregado)
);
COMMENT ON COLUMN historico_cargos.id_empregado IS 'Chave primária da tabela.';
COMMENT ON COLUMN historico_cargos.id_cargo IS 'Chave primária da tabela.';
COMMENT ON COLUMN historico_cargos.id_departamento IS 'Chave primária da tabela.';


ALTER TABLE empregados ADD CONSTRAINT cargos_empregados_fk
FOREIGN KEY (id_cargo)
REFERENCES cargos (id_cargo)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE historico_cargos ADD CONSTRAINT cargos_historico_cargos_fk
FOREIGN KEY (id_cargo)
REFERENCES cargos (id_cargo)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE paises ADD CONSTRAINT regioes_paises_fk
FOREIGN KEY (id_regiao)
REFERENCES regioes (id_regiao)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE localizacoes ADD CONSTRAINT paises_localizacoes_fk
FOREIGN KEY (id_pais)
REFERENCES paises (id_pais)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE departamentos ADD CONSTRAINT localizacoes_departamentos_fk
FOREIGN KEY (id_localizacao)
REFERENCES localizacoes (id_localizacao)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE empregados ADD CONSTRAINT departamentos_empregados_fk
FOREIGN KEY (id_departamento)
REFERENCES departamentos (id_departamento)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE historico_cargos ADD CONSTRAINT departamentos_historico_cargos_fk
FOREIGN KEY (id_departamento)
REFERENCES departamentos (id_departamento)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE historico_cargos ADD CONSTRAINT empregados_historico_cargos_fk
FOREIGN KEY (id_empregado)
REFERENCES empregados (id_empregado)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE empregados ADD CONSTRAINT empregados_empregados_fk
FOREIGN KEY (id_supervisor)
REFERENCES empregados (id_empregado)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE departamentos ADD CONSTRAINT empregados_departamentos_fk
FOREIGN KEY (id_gerente)
REFERENCES empregados (id_empregado)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;