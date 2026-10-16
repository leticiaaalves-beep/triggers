create table produtos(
id serial primary key,
nome varchar(150) not null,
preco numeric(10,2) not null
)

create table historico_precos(
id serial primary key,
produto_id int not null,
preco_antigo numeric(10,2),
preco_novo numeric(10,2),
data_alteracao timestamp default current_timestamp
)

create or replace function fn_log_alteracao_preco()
returns trigger as $$
begin
if old.preco is distinct from new.preco then 
insert into historico_precos(produto_id, preco_antigo, preco_novo) 
values (new.id, old.preco, new.preco);
end if;
return new;
end;
$$ language plpgsql;

create trigger trg_log_preco
after update on produtos
for each row 
execute function fn_log_alteracao_preco();

insert into produtos(nome, preco) values ('notebook gamer', 4500.00);

update produtos set preco = 4200.00 where id =1;

create table estoque(
id serial primary key,
nome_item varchar(150) not null,
quantidade int not null default 0
)

create or replace function fn_quantidade_estoque()
returns trigger as $$
begin
	if new.quantidade < 0 then 
		raise exception 'operação cancelada!O item "%" não pode ter estoque negativo (tentativa: % unidades)',
			new.nome_item, new.quantidade;
	end if;
	return new;
end;
$$ language plpgsql;

create trigger trg_validar_estoque
before insert or update on estoque
for each row
execute function fn_quantidade_estoque();

insert into estoque(nome_item, quantidade) values ('teclado mecanico', 10);
