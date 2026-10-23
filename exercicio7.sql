CREATE TABLE produtos(
id serial PRIMARY key,
nome VARCHAR(150) not null,
estoque_atual int not null default 0
)

CREATE TABLE itens_venda(
id serial PRIMARY key,
produto_id int not null,
FOREIGN KEY (produto_id) REFERENCES produtos(id),
quantidade_vendida int not null

)

CREATE or REPLACE FUNCTION fn_verificar_estoque()
RETURNS trigger as $$
declare 
v_estoque_atual int;
v_nome_produto VARCHAR(150);
BEGIN
select estoque_atual, nome INTO v_estoque_atual, v_nome_produto
FROM produtos
where id = new.produto_id;

if not found THEN
 RAISE EXCEPTION 'produto com id % não encontrado', new.produto_id;
 end if;

 if v_estoque_atual < new.quantidade_vendida  then
 	raise exception 'estoque insuficiente para o produto "%". disponivel: %, solicitado: % ',
	 v_nome_produto, v_estoque_atual, new.quantidade_vendida;
	 end if;

	 UPDATE produtos
    SET estoque_atual = estoque_atual - NEW.quantidade_vendida
    WHERE id = NEW.produto_id;

    RETURN NEW;
	END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER trg_verificar_estoque
BEFORE INSERT ON itens_venda
FOR EACH ROW
EXECUTE FUNCTION fn_verificar_estoque()