use taller78;
DELIMITER $$
CREATE PROCEDURE PA_INSERTAR_TRANSACCIONAL ( 
    in PIDCUENTAORIGEN int, 
    in PIDCUENTADESTINO int, 
    in PVALOR numeric(10,2))
BEGIN
    DECLARE errno int;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET CURRENT DIAGNOSTICS CONDITION 1 errno = MYSQL_ERRNO;
        SELECT errno AS MYSQL_ERROR;
        ROLLBACK;
    END;
    START TRANSACTION;
    insert into TRANSFERENCIA values(PIDCUENTAORIGEN, PIDCUENTADESTINO, PVALOR);
    insert into MOVIMIENTO(IDCUENTA,TIPOMOVIMIENTO,VALOR) values(PIDCUENTADESTINO, 'A', PVALOR);
    update CUENTA set SALDO=saldo+ PVALOR where IDCUENTA = PIDCUENTADESTINO ;
    insert into MOVIMIENTO(IDCUENTA,TIPOMOVIMIENTO,VALOR) values(PIDCUENTAORIGEN, 'D', PVALOR);
    update CUENTA set SALDO = saldo - PVALOR where IDCUENTA = PIDCUENTAORIGEN;
    COMMIT WORK;
END$$
DELIMITER ;
