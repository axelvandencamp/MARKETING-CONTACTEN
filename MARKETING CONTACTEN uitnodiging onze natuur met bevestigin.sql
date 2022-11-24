--=======lijst contactpersonen==========--
/*
SELECT cp.id cp_id, cp.parent_id cp_parent_id
FROM res_partner cp
WHERE cp.active AND COALESCE(cp.parent_id,0)>0
*/
SELECT --SQ1.id, SQ2.id, SQ3.id, SQ4.cp_id, SQ5.cp_id, SQ6.cp_id, p.id, cp.id, p.country_id, c.id, p.street_id, ccs.id, p.zip_id, cc.id, p2.partner_id,
	DISTINCT SQ1.id, SQ1.info, SQ4.cp_id, SQ4.cp_info cp_info, COALESCE(cp.name,p.name) naam,
	CASE 
		WHEN COALESCE(cp.name,'_') = '_' THEN p.name
		ELSE cp.name||' ('||p.name||')'
	END contact,
	CASE 
		WHEN COALESCE(SQ3.info,'_') <> '_' THEN SQ3.info
		WHEN COALESCE(SQ2.info,'_') <> '_' THEN SQ2.info ELSE 'geen reactie' 
	END reactie,
	CASE 
		WHEN COALESCE(SQ6.cp_info,'_') <> '_' THEN SQ6.cp_info
		WHEN COALESCE(SQ5.cp_info,'_') <> '_' THEN SQ5.cp_info ELSE 'geen reactie' 
	END cp_reactie,
	CASE 
		WHEN COALESCE(SQ6.cp_info,'_') <> '_' THEN SQ6.cp_info
		WHEN COALESCE(SQ5.cp_info,'_') <> '_' THEN SQ5.cp_info
		WHEN COALESCE(SQ3.info,'_') <> '_' THEN SQ3.info
		WHEN COALESCE(SQ2.info,'_') <> '_' THEN SQ2.info ELSE 'geen reactie' 
	END combi_reactie,
	CASE WHEN COALESCE(SQ5.cp_info,'_') LIKE '%1%' THEN 1
		WHEN COALESCE(SQ5.cp_info,'_') LIKE '%2%' THEN 2
		WHEN COALESCE(SQ5.cp_info,'_') LIKE '%3%' THEN 3
		WHEN COALESCE(SQ5.cp_info,'_') LIKE '%4%' THEN 4
		WHEN COALESCE(SQ5.cp_info,'_') LIKE '%5%' THEN 5
		WHEN COALESCE(SQ2.info,'_') LIKE '%1%' THEN 1
		WHEN COALESCE(SQ2.info,'_') LIKE '%2%' THEN 2
		WHEN COALESCE(SQ2.info,'_') LIKE '%3%' THEN 3
		WHEN COALESCE(SQ2.info,'_') LIKE '%4%' THEN 4
		WHEN COALESCE(SQ2.info,'_') LIKE '%5%' THEN 5
		ELSE 0
	END aantal,
	CASE WHEN COALESCE(cp.id,0) > 0 THEN p.last_name END bedrijf_vereniging,
	CASE WHEN COALESCE(cp.id,0) > 0 THEN cp.first_name ELSE p.first_name END voornaam,
	CASE WHEN COALESCE(cp.id,0) > 0 THEN cp.last_name ELSE p.last_name END achternaam,
	CASE WHEN COALESCE(cp.id,0) > 0 THEN COALESCE(cp.email_work,cp.email) ELSE COALESCE(p.email_work,p.email) END email,
	CASE WHEN COALESCE(cp.id,0) > 0 THEN COALESCE(cp.phone_work,cp.phone) ELSE COALESCE(p.phone_work,p.phone) END telefoonnr,
	CASE WHEN COALESCE(cp.id,0) > 0 THEN cp.mobile ELSE p.mobile END gsm,
	p.street2 huisnaam,
	CASE
		WHEN c.id = 21 AND p.crab_used = 'true' THEN ccs.name
		ELSE p.street
	END straat,
	CASE
		WHEN c.id = 21 AND p.crab_used = 'true' THEN p.street_nbr ELSE ''
	END huisnummer, 
	p.street_bus bus,
	CASE
		WHEN c.id = 21 AND p.crab_used = 'true' THEN cc.zip
		ELSE p.zip
	END postcode,
	CASE 
		WHEN c.id = 21 THEN cc.name ELSE p.city 
	END woonplaats,
	p.postbus_nbr postbus,
	CASE
		WHEN p.country_id = 21 AND substring(p.zip from '[0-9]+')::numeric BETWEEN 1000 AND 1299 THEN 'Brussel' 
		WHEN p.country_id = 21 AND (substring(p.zip from '[0-9]+')::numeric BETWEEN 1500 AND 1999 OR substring(p.zip from '[0-9]+')::numeric BETWEEN 3000 AND 3499) THEN 'Vlaams Brabant'
		WHEN p.country_id = 21 AND substring(p.zip from '[0-9]+')::numeric BETWEEN 2000 AND 2999  THEN 'Antwerpen' 
		WHEN p.country_id = 21 AND substring(p.zip from '[0-9]+')::numeric BETWEEN 3500 AND 3999  THEN 'Limburg' 
		WHEN p.country_id = 21 AND substring(p.zip from '[0-9]+')::numeric BETWEEN 8000 AND 8999  THEN 'West-Vlaanderen' 
		WHEN p.country_id = 21 AND substring(p.zip from '[0-9]+')::numeric BETWEEN 9000 AND 9999  THEN 'Oost-Vlaanderen' 
		WHEN p.country_id = 21 THEN 'Wallonië'
		WHEN p.country_id = 166 THEN 'Nederland'
		WHEN NOT(p.country_id IN (21,166)) THEN 'Buitenland niet NL'
		ELSE 'andere'
	END AS provincie,
	_crm_land(c.id) land,
	p2.lid, p2.donateur, p2.erflater, p2.commerciële_partner, p2.bos_partner, p2.major_donor, p2.schenker_grond		
FROM
	-- SQ1 --hoofdcontact "uitnodiging"--
	(SELECT DISTINCT p.id, mei.info, mei.create_date::date
	FROM res_partner p
		--marketing contacten info
		LEFT OUTER JOIN crm_marketing_partner_type_rel mptr ON mptr.partner_type_id = p.id
		LEFT OUTER JOIN res_crm_marketing_partner_type mpt ON mpt.id = mptr.name
		LEFT OUTER JOIN res_crm_marketing_extra_info mei ON mei.info_id = p.id
	WHERE LOWER(mei.info) LIKE '%onze natuur%' AND LOWER(mei.info) LIKE '%uitnodiging%'
		-- enkel selectie van effectieve Marketing Contacten om Contact Personen hier uit te sluiten
		AND (p.id IN (SELECT partner_type_id FROM crm_marketing_partner_type_rel))
	ORDER BY p.id DESC) SQ1
	LEFT OUTER JOIN
	-- SQ2 --hoofdcontact "bevestiging"--
	(SELECT DISTINCT p.id, mei.info, mei.create_date::date
	FROM res_partner p
		--marketing contacten info
		LEFT OUTER JOIN crm_marketing_partner_type_rel mptr ON mptr.partner_type_id = p.id
		LEFT OUTER JOIN res_crm_marketing_partner_type mpt ON mpt.id = mptr.name
		LEFT OUTER JOIN res_crm_marketing_extra_info mei ON mei.info_id = p.id
	WHERE LOWER(mei.info) LIKE '%onze natuur%' AND LOWER(mei.info) LIKE '%bevestiging%'
		-- enkel selectie van effectieve Marketing Contacten om Contact Personen hier uit te sluiten
		AND (p.id IN (SELECT partner_type_id FROM crm_marketing_partner_type_rel))
	ORDER BY p.id DESC) SQ2 ON SQ2.id = SQ1.id
	LEFT OUTER JOIN
	-- SQ3 --hoofdcontact "komt niet"--
	(SELECT DISTINCT p.id, mei.info, mei.create_date::date
	FROM res_partner p
		--marketing contacten info
		LEFT OUTER JOIN crm_marketing_partner_type_rel mptr ON mptr.partner_type_id = p.id
		LEFT OUTER JOIN res_crm_marketing_partner_type mpt ON mpt.id = mptr.name
		LEFT OUTER JOIN res_crm_marketing_extra_info mei ON mei.info_id = p.id
	WHERE LOWER(mei.info) LIKE '%onze natuur%' AND LOWER(mei.info) LIKE '%niet aanwezig%'
		-- enkel selectie van effectieve Marketing Contacten om Contact Personen hier uit te sluiten
		AND (p.id IN (SELECT partner_type_id FROM crm_marketing_partner_type_rel))
	ORDER BY p.id DESC) SQ3 ON SQ3.id = SQ1.id
	LEFT OUTER JOIN
	-- SQ4 --contactpersoon "uitnodiging"--
	(SELECT DISTINCT cp.id cp_id, cp.parent_id cp_parent_id, mei.info cp_info
	FROM res_partner cp
		JOIN res_crm_marketing_extra_info mei ON mei.info_id = cp.id 
		LEFT OUTER JOIN res_partner_title pt ON cp.title = pt.id
	 WHERE cp.active
		AND LOWER(mei.info) LIKE '%onze natuur%' AND LOWER(mei.info) LIKE '%uitnodiging%') SQ4 ON SQ4.cp_parent_id = SQ1.id
	LEFT OUTER JOIN
	-- SQ5 --contactpersoon "bevestiging"--
	(SELECT DISTINCT cp.id cp_id, cp.parent_id cp_parent_id, mei.info cp_info
	FROM res_partner cp
		JOIN res_crm_marketing_extra_info mei ON mei.info_id = cp.id 
		LEFT OUTER JOIN res_partner_title pt ON cp.title = pt.id
	 WHERE cp.active
		AND LOWER(mei.info) LIKE '%onze natuur%' AND LOWER(mei.info) LIKE '%bevestiging%') SQ5 ON SQ5.cp_parent_id = SQ4.cp_parent_id
	LEFT OUTER JOIN
	-- SQ6 --contactpersoon "niet aanwezig"
	(SELECT DISTINCT cp.id cp_id, cp.parent_id cp_parent_id, mei.info cp_info
	FROM res_partner cp
		JOIN res_crm_marketing_extra_info mei ON mei.info_id = cp.id 
		LEFT OUTER JOIN res_partner_title pt ON cp.title = pt.id
	 WHERE cp.active
		AND LOWER(mei.info) LIKE '%onze natuur%' AND LOWER(mei.info) LIKE '%niet aanwezig%') SQ6 ON SQ6.cp_parent_id = SQ4.cp_parent_id
	JOIN res_partner p ON p.id = SQ1.id
	LEFT OUTER JOIN res_partner cp ON cp.id = SQ4.cp_id
	-- --hoofdcontact-- land, straat, gemeente info
	JOIN res_country c ON p.country_id = c.id
	LEFT OUTER JOIN res_country_city_street ccs ON p.street_id = ccs.id
	LEFT OUTER JOIN res_country_city cc ON p.zip_id = cc.id
	--marketing partner info
	JOIN marketing._m_dwh_partners p2 ON p2.partner_id = p.id
--WHERE cp.id = 373681	
--ORDER BY p.id	
