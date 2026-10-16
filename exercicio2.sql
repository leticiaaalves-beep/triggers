create table contas(
id serial primary key,
nome varchar(150) not null,
saldo numeric(10,2) not null default 0.00
)

CREATE TABLE movimentacoes (
    id SERIAL PRIMARY KEY,
    conta_id INT REFERENCES contas(id),
    tipo VARCHAR(1) CHECK (tipo IN ('c', 'd')),
    valor NUMERIC(10, 2) NOT NULL,
    data_movimentacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP
)

CREATE or replace function fn_atualiza_saldo_conta()
returns trigger as $$
begin
	if new.tipo = 'c' then
update contas SET saldo = saldo + new.valor WHERE id = new.conta_id;
	elsif new.tipo = 'd' then
update contas set saldo = saldo - new.valor where id = new.conta_id;
	end if;
	return new;
end;
$$ language plpgsql;
create trigger tg_saldo_atualizado
after insert on movimentacoes
for each row
EXECUTE FUNCTION fn_atualiza_saldo_conta();

insert into contas(nome, saldo) values
('João Silva', 500.00)

insert into movimentacoes (conta_id, tipo, valor) values
(1, 'd', 150.00)


