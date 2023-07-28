
----SQL Programming Basics

CREATE PROCEDURE sp_sampleproc_1 AS
BEGIN
	SELECT 'HELLO WORLD' AS [Message]

END;


EXECUTE sp_sampleproc_1;

EXEC sp_sampleproc_1;

sp_sampleproc_1;



ALTER PROCEDURE sp_sampleproc_1 AS
BEGIN
	PRINT 'HELLO WORLD'

END;


EXEC sp_sampleproc_1


---------------------------------

CREATE TABLE ORDER_TBL
(
ORDER_ID TINYINT NOT NULL,
CUSTOMER_ID TINYINT NOT NULL,
CUSTOMER_NAME VARCHAR(50),
ORDER_DATE DATE,
EST_DELIVERY_DATE DATE--estimated delivery date
);


INSERT ORDER_TBL VALUES (1, 1, 'Adam', GETDATE()-10, GETDATE()-5 ),
						(2, 2, 'Smith',GETDATE()-8, GETDATE()-4 ),
						(3, 3, 'John',GETDATE()-5, GETDATE()-2 ),
						(4, 4, 'Jack',GETDATE()-3, GETDATE()+1 ),
						(5, 5, 'Owen',GETDATE()-2, GETDATE()+3 ),
						(6, 6, 'Mike',GETDATE(), GETDATE()+5 ),
						(7, 6, 'Rafael',GETDATE(), GETDATE()+5 ),
						(8, 7, 'Johnson',GETDATE(), GETDATE()+5 );

SELECT	*
FROM	ORDER_TBL;

---------


CREATE TABLE ORDER_DELIVERY
(
ORDER_ID TINYINT NOT NULL,
DELIVERY_DATE DATE -- tamamlanan delivery date
);


INSERT ORDER_DELIVERY VALUES (1, GETDATE()-6 ),
				(2, GETDATE()-2 ),
				(3, GETDATE()-2 ),
				(4, GETDATE() ),
				(5, GETDATE()+2 ),
				(6, GETDATE()+3 ),
				(7, GETDATE()+5 ),
				(8, GETDATE()+5 );

SELECT	*
FROM	ORDER_DELIVERY


--LET'S CREATE PROCEDURE THAT RETURN COUNT OF ORDERS AND RUN IT


CREATE PROC	sp_ord_count_1 AS
BEGIN
	SELECT	COUNT(ORDER_ID)
	FROM	ORDER_TBL
END;

EXEC sp_ord_count_1


---LET'S CREATE PROCEDURE THAT RETURNS MAX. ORDER AND RUN IT

CREATE PROC	sp_ord_count_2 AS
BEGIN
	SELECT	MAX(ORDER_ID)
	FROM	ORDER_TBL
END;

EXEC sp_ord_count_2


--LET'S INSERT VALUE TO OUR TABLE AND LET'S SEE HOW OUR PROCEDURE ACTS


INSERT ORDER_TBL VALUES(9,9, NULL, NULL, NULL);

SELECT	*
FROM	ORDER_TBL;

--AS WE UPDATE OUR TABLE, RESULT OF THE PROCEDURE WILL CHANGE:
--(Tablomuzu g�ncelledik�e prosed�r�n sonucu de�i�ecek)

EXECUTE sp_ord_count_2;






--ANOTHER PROCEDURE
--LET'S CREATE PROCEDURE THAT RETURNS COUNT OF ORDERS GIVEN IN DATE PARAMETER 
--(Verilen tarihte ka� tane sipari� oldu�unu d�nen bir prosed�r yazal�m)

CREATE PROC	sp_sample_proc1 ( @ORD_DATE DATE )
AS

BEGIN
	SELECT  COUNT(ORDER_ID)
	FROM	ORDER_TBL
	WHERE	ORDER_DATE = @ORD_DATE
END;

EXEC sp_sample_proc1 '2023-07-28'




--DEFINE A PROCEDURE THAT RETURNS THE ORDER DETAILS OF DESIRED CUSTOMER ON THE REQUESTED DATE:
--(�stenilen m��terinin istenilen tarihteki sipari� bilgilerini d�nd�ren bir proc. tan�mlay�n):


CREATE PROC sp_customer_orders_1 ( @CUST VARCHAR(50), @DAY DATE = '2023-07-22' )
--WE CAN DEFINE DEFAULT VALUE FOR PARAMETERS WHICH WILL RETURN IF NOTHING ENTERED
AS
BEGIN
	SELECT	*
	FROM	ORDER_TBL
	WHERE	CUSTOMER_NAME = @CUST
	AND ORDER_DATE = @DAY
END;


EXEC sp_customer_orders_1 'Jack' ;

EXEC sp_customer_orders_1 'Jack' , '2023-07-25';


-------------