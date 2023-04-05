DROP TABLE IF EXISTS _AV_myvar;
CREATE TEMP TABLE _AV_myvar 
	(prm_periode text,prm_startdatum date,prm_einddatum date,prm_marketingcontact_type integer);
INSERT INTO _AV_myvar VALUES('YTD', -- prm_periode
							 '1999-01-01',	--prm_startdatum
							 '1999-12-31',	--prm_einddatum
							 '2' --prm_marketingcontact_type
				);
SELECT * FROM _AV_myvar;
--=============================================================
-- SELECT * FROM res_crm_marketing_partner_type mpt

SELECT mi.date, mi.amount, 
	CASE 
		WHEN mi.grootboekrek IN ('732100','732000') THEN 'Gift'
		WHEN mi.grootboekrek IN ('740500') THEN 'Sponsoring'
		WHEN mi.grootboekrek IN ('734000') THEN 'Legaat' ELSE ''
	END inkomsten_type,
	mi.partner_id, mp.name, mi.partner,
	mi.project_code, mi.project, mi.grootboekrek, mi.rechtspersoon, mi.vzw
--SELECT *
FROM _AV_myvar v, 
	marketing._m_sproc_rpt_marketingcontactenopvolginginkomsten(v.prm_periode,v.prm_startdatum,v.prm_einddatum) mi
	JOIN (SELECT p.id, mpt.name
		FROM _AV_myvar v, res_partner p
			JOIN crm_marketing_partner_type_rel mptr ON mptr.partner_type_id = p.id
			JOIN res_crm_marketing_partner_type mpt ON mpt.id = mptr.name
		WHERE CASE 
		  	WHEN COALESCE( v.prm_marketingcontact_type ,0) <> 0
		  		THEN mpt.id =  v.prm_marketingcontact_type   ELSE mpt.id <> 0
		 	END) mp
		ON mp.id = mi.partner_id
		
SELECT id, name FROM res_crm_marketing_partner_type	
SELECT id, name FROM res_crm_marketing_partner_type
		
		

	
