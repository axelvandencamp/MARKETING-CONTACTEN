SELECT sq1.id, test,
	CASE WHEN COALESCE(sq1.cp_aanspreking,sq1.aanspreking) = 'Dhr.' THEN 'heer'
		 WHEN COALESCE(sq1.cp_aanspreking,sq1.aanspreking) = 'Mevr.' THEN 'mevrouw'
		 ELSE COALESCE(sq1.cp_aanspreking,sq1.aanspreking)
	END aanspreking,
	COALESCE(sq1.cp_last_name,sq1.last_name) naam,
	COALESCE(sq1.cp_email,sq1.email) email,
	COALESCE(sq1.cp_first_name,sq1.first_name) voornaam,
	sq1.donateur, sq1.erflater, sq1.commerciële_partner, sq1.bos_partner, sq1.major_donor, sq1.schenker_grond, *
FROM
	(SELECT DISTINCT p.id, 
	 	ascii(mei.info) test,
		CASE
			WHEN p.gender = 'M' THEN 'Dhr.'
			WHEN p.gender = 'V' THEN 'Mevr.'
			ELSE pt.shortcut
		END aanspreking,
		p.first_name, p.last_name, 
	 	REPLACE(REPLACE(REPLACE(REPLACE(regexp_REPLACE(REPLACE(REPLACE(mei.info,',',';'),chr(9),';'),chr(10),';','g'),chr(11),';'),chr(12),';'),chr(13),';'),chr(160),';') info, 
	 	mei.create_date::date,  
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
		_crm_land(c.id) land,
		COALESCE(p.email,p.email_work) email,
		cp.cp_id contactpersoon_id, cp.cp_aanspreking, cp.cp_first_name cp_first_name, cp.cp_last_name, 
	 	--cp.mei_info cp_mei_info, 
	 	REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(cp.mei_info,',',';'),chr(9),';'),chr(10),';'),chr(11),';'),chr(12),';'),chr(13),';'),chr(160),';') cp_mei_info, 
	 	cp.cp_function cp_functie, cp.cp_email, cp.cp_telefoonnr, cp.cp_mobile cp_gsm,
		p2.lid, p2.donateur, p2.erflater, p2.commerciële_partner, p2.bos_partner, p2.major_donor, p2.schenker_grond
	FROM res_partner p
		--partner info
		JOIN marketing._m_dwh_partners p2 ON p2.partner_id = p.id
		--land, straat, gemeente info
		JOIN res_country c ON p.country_id = c.id
		--aanspreking
		LEFT OUTER JOIN res_partner_title pt ON p.title = pt.id
		--marketing contacten info
		LEFT OUTER JOIN crm_marketing_partner_type_rel mptr ON mptr.partner_type_id = p.id
		LEFT OUTER JOIN res_crm_marketing_partner_type mpt ON mpt.id = mptr.name
		LEFT OUTER JOIN res_crm_marketing_extra_info mei ON mei.info_id = p.id
		LEFT OUTER JOIN res_users u ON u.id = mei.author
		--donateursprofiel info
		--LEFT OUTER JOIN marketing._m_dwh_donateursprofiel dp ON dp.partner_id = p.id
		--contactpersoon met "uitnodiging onze natuur" in extra info
		LEFT OUTER JOIN	(SELECT cp.id cp_id, cp.parent_id cp_parent_id, 
								CASE
									WHEN COALESCE(cp.gender,'_') = 'M' THEN 'Dhr.'
									WHEN COALESCE(cp.gender,'_') = 'V' THEN 'Mevr.'
									ELSE pt.shortcut
								END cp_aanspreking,
						 cp.first_name cp_first_name, cp.last_name cp_last_name, cp.function cp_function, cp.email cp_email, COALESCE(cp.phone_work,cp.phone) cp_telefoonnr, cp.mobile cp_mobile
								,mei.info mei_info
						FROM res_partner cp
							JOIN res_crm_marketing_extra_info mei ON mei.info_id = cp.id AND LOWER(mei.info) LIKE ('%bedank%') 
							LEFT OUTER JOIN res_partner_title pt ON cp.title = pt.id
						 WHERE cp.active) cp ON cp.cp_parent_id = p.id
		--adres info
		LEFT OUTER JOIN res_country_city_street ccs ON p.street_id = ccs.id
		LEFT OUTER JOIN res_country_city cc ON p.zip_id = cc.id
	WHERE LOWER(mei.info) LIKE '%bedank%'
		-- enkel selectie van effectieve Marketing Contacten om Contact Personen hier uit te sluiten
		--AND (p.id IN (SELECT partner_type_id FROM crm_marketing_partner_type_rel))
		AND p.active --AND mpt.name LIKE ('Donateur%')
		--AND p.id = 259282
	ORDER BY p.id DESC) sq1
ORDER BY sq1.donateur, sq1.erflater, sq1.major_donor, sq1.schenker_grond, sq1.commerciële_partner, sq1.bos_partner DESC	

/*
SELECT p.id, pt.*
FROM res_partner p
	--aanspreking
	LEFT OUTER JOIN res_partner_title pt ON p.title = pt.id
WHERE p.id = 	381353

SELECT p.id, *
FROM res_partner p
	--marketing contacten info
	LEFT OUTER JOIN crm_marketing_partner_type_rel mptr ON mptr.partner_type_id = p.id
	LEFT OUTER JOIN res_crm_marketing_partner_type mpt ON mpt.id = mptr.name
	--contactpersoon
	LEFT OUTER JOIN res_partner cp ON cp.parent_id = p.id
WHERE COALESCE(mpt.name,'_') <> '_'

--- partner & contact persoon
SELECT p.id, p.name, cp.cp_id, cp.cp_name
FROM res_partner p
	--contactpersoon
	LEFT OUTER JOIN	(SELECT cp.id cp_id, cp.parent_id cp_parent_id, cp.name cp_name
					FROM res_partner cp
						JOIN res_crm_marketing_extra_info mei_cp ON mei_cp.info_id = cp.id AND LOWER(mei_cp.info) LIKE ('uitnodiging%')) cp ON cp.cp_parent_id = p.id
--WHERE cp.cp_id = 381126
WHERE p.id = 15323
*/

/*
SELECT * FROM res_partner WHERE id = 366463 LIMIT 10
SELECT * FROM crm_marketing_partner_type_rel WHERE partner_type_id = 381126
SELECT * FROM res_crm_marketing_partner_type
SELECT * FROM res_crm_marketing_contact_fase
SELECT * FROM res_crm_marketing_contact_history
SELECT * FROM res_users WHERE login IN ('axel.vandencamp','jimmy.vanlooy','griet.vandendriessche')
SELECT * FROM res_users WHERE login LIKE ('griet.vanden%')
*/