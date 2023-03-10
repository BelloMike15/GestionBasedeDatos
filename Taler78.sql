use taller78;
create table CUENTA (
    IDCUENTA int not null,
    SALDO numeric(10,2) null,
    constraint PK_CUENTA primary key nonclustered (IDCUENTA)
);

ALTER TABLE CUENTA ADD  CHECK (SALDO>=0);

create table MOVIMIENTO (
    IDMOVIMIENTO int  not null AUTO_INCREMENT,
    IDCUENTA int null,
    TIPOMOVIMIENTO varchar(2) null,
    VALOR numeric(10,2) null,
    constraint PK_MOVIMIENTO primary key nonclustered (IDMOVIMIENTO)
);

create table TRANSFERENCIA (
    IDCUENTAORIGEN int null,
    IDCUENTADESTINO int null,
    IMPORTE numeric(10,2) null
) ;

alter table MOVIMIENTO
add constraint FK_MOVIMIEN_FK3_CUENTA foreign key (IDCUENTA)
references CUENTA (IDCUENTA) ;

alter table TRANSFERENCIA
add constraint FK_cuentadestino_CUENTA foreign key (IDCUENTADESTINO)
references CUENTA (IDCUENTA) ;

alter table TRANSFERENCIA
add constraint FK_cuentaorigen_CUENTA foreign key (IDCUENTAORIGEN)
references CUENTA (IDCUENTA);


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


DELIMITER $$
CREATE PROCEDURE PA_INSERTAR_NOTRANSACCIONAL ( 
    in PIDCUENTAORIGEN int, 
    in PIDCUENTADESTINO int, 
    in PVALOR numeric(10,2))
BEGIN
    
    START TRANSACTION;
    insert into TRANSFERENCIA values(PIDCUENTAORIGEN, PIDCUENTADESTINO, PVALOR);
    insert into MOVIMIENTO(IDCUENTA,TIPOMOVIMIENTO,VALOR) values(PIDCUENTADESTINO, 'A', PVALOR);
    update CUENTA set SALDO=saldo+ PVALOR where IDCUENTA = PIDCUENTADESTINO ;
    insert into MOVIMIENTO(IDCUENTA,TIPOMOVIMIENTO,VALOR) values(PIDCUENTAORIGEN, 'D', PVALOR);
    update CUENTA set SALDO = saldo - PVALOR where IDCUENTA = PIDCUENTAORIGEN;
    
END$$
DELIMITER ;


DELETE FROM TRANSFERENCIA;
DELETE FROM MOVIMIENTO;
DELETE FROM CUENTA;
INSERT INTO CUENTA VALUES(1,200),(2,0);
use taller78;
SELECT * FROM CUENTA;
