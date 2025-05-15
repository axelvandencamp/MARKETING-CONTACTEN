DROP TABLE IF EXISTS _AV_myvar;
CREATE TEMP TABLE _AV_myvar 
	(prm_periode text,prm_startdatum date,prm_einddatum date,prm_marketingcontact_type integer);
INSERT INTO _AV_myvar VALUES('CST', -- prm_periode
							 '2024-01-01',	--prm_startdatum
							 '2025-12-31',	--prm_einddatum
							 '2' --prm_marketingcontact_type
				);
SELECT * FROM _AV_myvar;
--=============================================================
/*SELECT sq1.aaa_id, sq1.aaa_create_date, sq1.aaa_name, sq1.aaa_partner_id, 
		sq1.partner_id, sq1.partner,
		SUM(sq1.mi_amount) bedrag, sq1.mi_grootboekrek, sq1.mi_grootboekrek_naam, sq1.mi_project, sq1.mi_project_code, sq1.mi_boeking, sq1.mi_vzw
*/
SELECT sq1.partner_id, sq1.display_name "[id]_partner", sq1.partner, sq1.mi_project, sq1.mi_project_code, sq1.mi_vzw	
FROM 
	(
	SELECT aaa.id aaa_id, aaa.create_date aaa_create_date, aaa.name aaa_name, aaa.parent_id, aaa.partner_id aaa_partner_id,
		p.id partner_id, p.name partner, '['||p.id||'] '||p.name display_name,
		mi.amount mi_amount, mi.grootboekrek mi_grootboekrek, mi.grootboekrek_naam mi_grootboekrek_naam, mi.project mi_project, mi.project_code mi_project_code, mi.boeking mi_boeking, mi.vzw mi_vzw--, mi.*,
	FROM _AV_myvar v, 
		account_analytic_account aaa
		--JOIN account_analytic_dimension aad ON aad.id = aaa.dimension_id
		JOIN marketing._m_sproc_rpt_marketingcontactenopvolginginkomsten(v.prm_periode,v.prm_startdatum,v.prm_einddatum) mi ON mi.partner_id = aaa.partner_id AND mi.project_code = aaa.code
		JOIN res_partner p ON p.id = aaa.partner_id
	WHERE aaa.active
		AND LOWER(aaa.code) LIKE 'c-cp-%' 
	) sq1
/*GROUP BY sq1.partner_id, sq1.partner,
		sq1.mi_grootboekrek, sq1.mi_grootboekrek_naam, sq1.mi_project, sq1.mi_project_code, 
		sq1.aaa_id, sq1.aaa_create_date, sq1.aaa_name, sq1.aaa_partner_id, sq1.mi_boeking, sq1.mi_vzw	
*/
GROUP BY sq1.partner_id, sq1.display_name, sq1.partner, sq1.mi_project, sq1.mi_project_code, sq1.mi_vzw
--ORDER BY sq1.partner_id, sq1.mi_grootboekrek, sq1.mi_project_code, sq1.mi_boeking
ORDER BY sq1.partner_id, sq1.mi_project_code --, sq1.mi_boeking
	





/*
--WHERE aaa.code = 'C-CP-000526'
WHERE LOWER(name) LIKE '%schwabe%'


SELECT * FROM account_analytic_dimension WHERE id = 15
*/