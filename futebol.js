const { Client } = require('pg');
const async = require('async');
const hoaxer = require('hoaxer');
const cpfCheck = require('cpf-check');
const fs = require('fs').promises;
const moment = require('moment');
const tamanhoBanco = 5000;
let cpfAndpass = 0;

// Configuração de conexão com o banco de dados
const client = new Client({
    user: 'postgres',
    host: 'localhost',
    database: 'postgres',
    password: '1227',
    port: 5432,
});

async function inserirDados(CaminhoArquivo, insertStatement, values) {
    let sql = insertStatement;
    let i = 1;
    for (const value of Object.values(values)) {
        sql = sql.replace(`$${i}`, typeof value === 'string' ? `'${value}'` : value);
        i++;
    }
    const query = {
        text: sql,
    };
    try {
        await client.query(query);
        console.log('Dados inseridos com sucesso!');
        fs.appendFile(CaminhoArquivo, `${sql}\n`);
        console.log('SQL gravado no arquivo com sucesso!');
    } catch (err) {
        console.error('Erro ao inserir dados:', err.stack);
    }
}

(async () => {
    try {
        await client.connect();
        console.log('Conexão com o banco de dados estabelecida com sucesso!');

        const commands = [
            "DELETE FROM jogo",
            "DELETE FROM cidade",
            "DELETE FROM equipe_campeonato",
            "DELETE FROM campeonato",
            "DELETE FROM paises_tecnicos",
            "DELETE FROM tecnico",
            "DELETE FROM jogador_brasileiro",
            "DELETE FROM jogador_estrangeiro",
            "DELETE FROM EQUIPE",
            "DELETE FROM funcionarios"
        ];

        for (const command of commands) {
            await client.query(command);
            console.log(`Tabela limpa: ${command}`);
        }

        // Inserir dados na tabela equipe
        console.log(`Iniciando Tabela equipe`);
        let insertStatement = "INSERT INTO EQUIPE (ID, NOME) VALUES ($1, $2)"; // <-- tentativa de redeclaração
        for (let i = 0; i < tamanhoBanco; i++) {
            const values = {
                id: i + 1,
                nome: hoaxer.commerce.productMaterial(),
            };
            await inserirDados('./InsertFutebol/equipe.sql', insertStatement, values);
        }

        // Inserir dados na tabela campeonato
        console.log(`Iniciando Tabela campeonato`);
        insertStatement = "INSERT INTO campeonato(id, nome) VALUES ($1, $2)";
        for (let i = 0; i < tamanhoBanco; i++) {
            const values = {
                id: i + 1,
                nome: hoaxer.company.companyName()
            };
            await inserirDados('./InsertFutebol/campeonato.sql', insertStatement, values);
        }

        // Inserir dados na tabela cidade
        console.log(`Iniciando Tabela cidade`);
        insertStatement = "INSERT INTO cidade(id, nome) VALUES ($1, $2)";
        for (let i = 0; i < tamanhoBanco; i++) {
            const values = {
                id: i + 1,
                nome: hoaxer.address.city()
            };
            await inserirDados('./InsertFutebol/cidade.sql', insertStatement, values);
        }

        // Inserir dados na tabela equipe_campeonato
        console.log(`Iniciando Tabela equipe_campeonato`);
        insertStatement = "INSERT INTO equipe_campeonato(id_equipe, id_campeonato, posicao) VALUES ($1, $2, $3)";
        for (let i = 0; i < tamanhoBanco; i++) {
            const values = {
                id_equipe: i + 1,
                id_campeonato: hoaxer.random.number({ min: 1, max: tamanhoBanco }),
                posicao: hoaxer.random.number({ min: 1, max: 20 })
            };
            await inserirDados('./InsertFutebol/equipeCampeonato.sql', insertStatement, values);
        }

        // Inserir dados na tabela tecnico
        console.log(`Iniciando Tabela tecnico`);
        insertStatement = "INSERT INTO tecnico(id, cpf, nome, id_equipe) VALUES ($1, $2, $3, $4)";
        for (let i = 1; i < tamanhoBanco; i++) {
            cpfAndpass = hoaxer.random.number({ min: 1000, max: 1000000, precision: 2 })
            const values = {
                id: i,
                num: cpfAndpass.toString(),
                nome: hoaxer.name.findName(),
                id_equipe: i
            };
            await inserirDados('./InsertFutebol/tecnico.sql', insertStatement, values);
        }

        // Inserir dados na tabela paises_tecnicos
        console.log(`Iniciando Tabela paises_tecnicos`);
        insertStatement = "INSERT INTO paises_tecnicos(id_tecnico, pais) VALUES ($1, $2)";
        for (let i = 0; i < tamanhoBanco; i++) {
            const values = {
                id_tecnico: i + 1,
                pais: hoaxer.address.country()
            };
            await inserirDados('./InsertFutebol/paisesTecnicos.sql', insertStatement, values);
        }

        // Inserir dados na tabela jogador_brasileiro
        console.log(`Iniciando Tabela jogador_brasileiro`);
        insertStatement = "INSERT INTO jogador_brasileiro(id, cpf, nome, posicao, id_equipe, salario) VALUES ($1, $2, $3, $4, $5, $6)";
        for (let i = 1; i < tamanhoBanco; i++) {
            cpfAndpass = hoaxer.random.number({ min: 1000, max: 1000000, precision: 2 })
            const values = {
                id: i,
                cpf: cpfAndpass.toString(),
                nome: hoaxer.name.findName(),
                posicao: hoaxer.random.arrayElement(['Atacante', 'Meio-Campo', 'Zagueiro', 'Goleiro']),
                id_equipe: i,
                salario: hoaxer.random.number({ min: 1000, max: 50000, precision: 2 })
            };
            await inserirDados('./InsertFutebol/jogadorBrasileiro.sql', insertStatement, values);
        }

        // Inserir dados na tabela jogador_estrangeiro
        console.log(`Iniciando Tabela jogador_estrangeiro`);
        insertStatement = "INSERT INTO jogador_estrangeiro(id, passaporte, nome, posicao, id_equipe, pais_origem, salario) VALUES ($1, $2, $3, $4, $5, $6, $7)";
        for (let i = 1; i < tamanhoBanco; i++) {
            cpfAndpass = hoaxer.random.number({ min: 1000, max: 1000000, precision: 2 })
            const values = {
                id: i,
                passaporte: cpfAndpass.toString(),
                nome: hoaxer.name.findName(),
                posicao: hoaxer.random.arrayElement(['Atacante', 'Meio-Campo', 'Zagueiro', 'Goleiro']),
                id_equipe: i,
                pais_origem: hoaxer.address.country(),
                salario: hoaxer.random.number({ min: 1000, max: 50000, precision: 2 })
            };
            await inserirDados('./InsertFutebol/jogadorEstrangeiro.sql', insertStatement, values);
        }

        // Inserir dados na tabela jogo
        console.log(`Iniciando Tabela jogo`);
        insertStatement = "INSERT INTO jogo(id, data_jogo, id_equipe_casa, id_equipe_fora, gols_equipe_casa, gols_equipe_fora, id_cidade, estadio, id_campeonato) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)";
        for (let i = 0; i < tamanhoBanco; i++) {
            const values = {
                id: i + 1,
                data_jogo: moment(hoaxer.date.past()).format('YYYY-MM-DD'),
                id_equipe_casa: hoaxer.random.number({ min: 1, max: 1000 }),
                id_equipe_fora: hoaxer.random.number({ min: 1, max: 1000 }),
                gols_equipe_casa: hoaxer.random.number({ min: 0, max: 5 }),
                gols_equipe_fora: hoaxer.random.number({ min: 0, max: 5 }),
                id_cidade: hoaxer.random.number({ min: 1, max: 1000 }),
                estadio: hoaxer.company.companyName(),
                id_campeonato: hoaxer.random.number({ min: 1, max: 1000 })
            };
            await inserirDados('./InsertFutebol/jogos.sql', insertStatement, values);
        }

        // Inserir dados na tabela funcionarios
        console.log(`Iniciando Tabela funcionarios`);
        insertStatement = "INSERT INTO funcionarios(codigo, nome_func, data_entrada, profissao, salario)VALUES ($1, $2, $3, $4, $5)";
        for (let i = 0; i < tamanhoBanco; i++) {
            const values = {
                codigo: i + 1,
                nome_func: hoaxer.name.findName(),
                data_entrada: moment(hoaxer.date.past()).format('YYYY-MM-DD'),
                profissao: hoaxer.random.arrayElement(['programador', 'designer', 'analista']),
                salario: hoaxer.random.number({ min: 1000, max: 10000 })
              };
            await inserirDados('./InsertFutebol/funcionarios.sql', insertStatement, values);
        }

    } finally {
        await client.end();
        console.log('Conexão com o banco de dados encerrada com sucesso!');
    }
})();