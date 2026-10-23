CREATE TABLE pedidos(
id serial primary key,
cliente VARCHAR(150) not null,
valor_total NUMERIC(10,2) not null default 0.00
)

CREATE TABLE itens_pedido(
id serial primary key,
pedido_id int not null,
FOREIGN KEY (pedido_id) REFERENCES pedidos(id),
produto_nome varchar(150) not null,
quantidade INT NOT null,
preco_unitario NUMERIC(10,2) not null

)

create or replace FUNCTION fn_recalcular_pedido()
RETURNS TRIGGER as $$
BEGIN
	if TG_OP = 'delete' THEN
update pedidos
set valor_total = (SELECT COALESCE(SUM(quantidade * preco_unitario), 0)
FROM itens_pedido
 WHERE pedido_id = OLD.pedido_id
)
WHERE id = NEW.pedido_id;
   END IF;

   RETURN NEW;
   END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tg_recalcular_total
AFTER INSERT OR UPDATE OR DELETE
ON itens_pedido
FOR EACH ROW
EXECUTE FUNCTION fn_recalcular_pedido();