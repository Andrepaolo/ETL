#DTIempo
insert into DTIEMPO (
	Fecha,
	Dia_cod,
    Dia_semana_desc,
    Mes_cod	,
    Mes_desc,
    Trim_cod,
    Trim_desc,
	Anio
)
SELECT 
	DATE_FORMAT(ve.Fecha_confirm, '%Y-%m-%d')  AS Fecha
	,DAYOFWEEK(ve.Fecha_confirm) AS DIA_CO	
	,DAYNAME(ve.Fecha_confirm ) AS DIA_SEMANA
	,MONTH(ve.Fecha_confirm ) AS COD_MES
	,MONTHNAME(ve.Fecha_confirm ) AS DES_MES
	,QUARTER( ve.Fecha_confirm ) AS COD_TRIMESTRE
	,CONCAT('Trimestre ', QUARTER(ve.Fecha_confirm )) AS DES_TRIMESTRE
	,YEAR(ve.Fecha_confirm ) AS COD_ANIO
FROM sisventdb.VENTA AS ve WHERE ve.Fecha_confirm IS NOT NULL
       GROUP BY DATE_FORMAT(ve.Fecha_confirm, '%Y-%m-%d')
       ORDER BY DATE_FORMAT(ve.Fecha_confirm, '%Y-%m-%d');

insert into DCLIENTE (
	Nom_cli
)
SELECT  c.Nom_cli FROM sisventdb.CLIENTE as c;

insert into DVENDEDOR (
	Nom_vend
)
SELECT  v.Nom_vend FROM sisventdb.VENDEDOR as v;

insert into DPRODUCTO (  -- L
	Cod_prod,
    Nom_prod,
    Prec_compra,
    Prec_venta,
	Nom_cat,
    Nom_fabric
)
SELECT
    p.Cod_prod,
    CONCAT(p.Nom_prod, p.Presentac, ' unidad ', p.Fracciones) AS Nom_prodxx,
    p.Prec_compra,
    p.Prec_venta,
    c.Nom_cat,
    f.Nom_fabric
FROM sisventdb.PRODUCTO AS p
INNER JOIN sisventdb.CATEGORIA AS c ON p.Cat_id = c.Cat_id
INNER JOIN sisventdb.LOTE AS l ON c.Lote_id = l.Lote_id
INNER JOIN sisventdb.FABRICA AS f ON l.Fabric_id = f.Fabric_id;

insert into DTIENDA(  -- L
	Nom_Tienda,
    Direccion,
    Distrito,
    Provincia,
	Departamento,
)
SELECT
    t.Nom_tiend AS Nom_Tienda,
    t.Direccion AS Direccion,
    
    di.Nom_dist AS Distrito,
    prov.Nom_prov AS Provincia,
    de.Nom_dep AS Departamento
FROM sisventdb.TIENDA AS t
INNER JOIN sisventdb.DISTRITO AS di ON t.Dist_id = di.Dist_id
INNER JOIN sisventdb.PROVINCIA AS prov ON di.Prov_id = prov.Prov_id
INNER JOIN sisventdb.DEPARTAMENTO AS de ON prov.Dep_id = de.Dep_id;


insert into DMETODPAGO(  
	Metodo_de_Pago,
    Organizacion
)
SELECT 
M.Nom_pago AS Metodo_de_Pago, 
MT.Nom_mpt AS Organizacion
FROM METODPAGO M
INNER JOIN MP_Tipo MT ON M.Mpago_id = MT.Mpago_id;





#tabla hecho venta
SELECT
    DATE_FORMAT(ve.Fecha_crea, '%Y-%m-%d') AS Fecha,
    TIMESTAMPDIFF(MINUTE, ve.Fecha_crea, ve.Fecha_confirm) AS min_confirmacion,
    TIMESTAMPDIFF(MINUTE, ve.Fecha_confirm, ve.Fecha_envio) AS min_despacho,
    ROUND(TIME_TO_SEC(TIMEDIFF(ve.Fecha_entrega, ve.Fecha_envio)) / 3600, 2) AS horas_entrega2,
    p.Cod_prod,
    p.Nom_prod,
    c.Nom_cat,
    l.Nom_lote,
    f.Nom_fabric,
    SUM(ped.Cantidad) AS Cantidad,
    SUM(ped.Cantidad * ped.Prec_compra_un) AS Costos,
    SUM(ped.Cantidad * (ped.Prec_venta_un - ped.Total_desc_un)) AS Ventas,
    SUM(ped.Cantidad * ped.Total_desc_un) AS Descuentos,
    SUM((ped.Cantidad * (ped.Prec_venta_un - ped.Total_desc_un)) - (ped.Cantidad * ped.Prec_compra_un)) AS Ganancia,
    cli.Nom_cli,
    v.Nom_vend,
    ve.Vta_id AS Cod_Venta
FROM sisventdb.VENTA AS ve
INNER JOIN sisventdb.CLIENTE AS cli ON ve.Cli_id = cli.Cli_id
INNER JOIN sisventdb.VENDEDOR AS v ON ve.Vend_id = v.Vend_id
INNER JOIN sisventdb.VENTA_DET AS ped ON ve.Vta_id = ped.Vta_id
INNER JOIN sisventdb.PRODUCTO AS p ON ped.Prod_id = p.Prod_id
INNER JOIN sisventdb.CATEGORIA AS c ON p.Cat_id = c.Cat_id
INNER JOIN sisventdb.LOTE AS l ON c.Lote_id = l.Lote_id
INNER JOIN sisventdb.FABRICA AS f ON l.Fabric_id = f.Fabric_id
GROUP BY ve.Vta_id;
