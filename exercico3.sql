create table funcionarios(
id serial primary key,
nome varchar(150) not null,
cargo varchar(100) not null,
salario numeric(10,2) default 0.00
 )

  create table historico_carreira(
id serial primary key,
funcionario_id int not null,
foreign key (funcionario_id) references funcionarios(id),
cargo_antigo varchar(150),
cargo_novo varchar(150),
salario_antigo numeric(10,2),
salario_novo numeric(10,2),
data_alteracao timestamp default current_timestamp
)

create or replace function fn_atualizacao_funcionarios()
returns trigger as $$
begin
 	if old.cargo is distinct  from new.cargo  or old.salario is DISTINCT from new.salario then
	 insert into historico_carreira (funcionario_id, cargo_antigo, cargo_novo, salario_antigo, salario_novo)
	 values (old.id, old.cargo, new.cargo, old.salario, new.salario );
	 end if;
	 RETURN new;
	 end;

$$ language plpgsql;

create trigger trg_atualizacao_funcionario
AFTER UPDATE on funcionarios
for each row
execute function fn_atualizacao_funcionarios()

