-- unieke "extra info" per "status/fase" voor specifiek "status/fase"
SELECT DISTINCT mcf.id, mcf.name, mei.info, mei.datetime::date
FROM res_partner p
	JOIN res_crm_marketing_contact_history mch ON mch.history_id = p.id
	JOIN res_crm_marketing_contact_fase mcf ON mcf.id = mch.contact_fase
	JOIN res_crm_marketing_extra_info mei ON mei.info_id = mch.history_id AND mei.datetime::date = mch.datetime::date
--WHERE mcf.id IN (24,25,26)
WHERE mcf.id = 24
ORDER by mcf.id
------------------------------------
SELECT DISTINCT mch.history_id, mcf.name, mei.info
FROM res_partner p
	JOIN res_crm_marketing_contact_history mch ON mch.history_id = p.id
	JOIN res_crm_marketing_contact_fase mcf ON mcf.id = mch.contact_fase
	JOIN res_crm_marketing_extra_info mei ON mei.info_id = mch.history_id AND mei.datetime::date = mch.datetime::date
WHERE mcf.id = 24

-----------------------------------
-- opvolging response LEDENWERVING
-----------------------------------
SELECT sq1.*, p.id, p.name, p.membership_state, p.active,
	p.membership_start Lidmaatschap_startdatum, 
	p.membership_stop Lidmaatschap_einddatum,  
	p.membership_pay_date betaaldatum,
	p.membership_renewal_date hernieuwingsdatum,
	p.membership_end recentste_einddatum_lidmaatschap,
	p.membership_cancel membership_cancel
FROM res_partner p
	JOIN (SELECT DISTINCT p.id partner_id, mcf.name, mei.info, mch.datetime::date date
					FROM res_partner p
						JOIN res_crm_marketing_contact_history mch ON mch.history_id = p.id
						JOIN res_crm_marketing_contact_fase mcf ON mcf.id = mch.contact_fase
						JOIN res_crm_marketing_extra_info mei ON mei.info_id = mch.history_id AND mei.datetime::date = mch.datetime::date
					WHERE mcf.id = 26) sq1
				ON sq1.partner_id = p.id
-----------------------------------
-- opvolging response LEDENSERVICE
-----------------------------------
SELECT sq1.partner_id, sq1.status, sq1.info, u.login, sq1.date, p.id, p.name, p.membership_state, p.active,
	p.membership_start Lidmaatschap_startdatum, 
	p.membership_stop Lidmaatschap_einddatum,  
	p.membership_pay_date betaaldatum,
	p.membership_renewal_date hernieuwingsdatum,
	p.membership_end recentste_einddatum_lidmaatschap,
	p.membership_cancel membership_cancel
FROM res_partner p
	JOIN (SELECT DISTINCT p.id partner_id, mcf.name status, mei.info, mch.author, /*mei.datetime::date,*/ mch.datetime::date date
					FROM res_partner p
						JOIN res_crm_marketing_contact_history mch ON mch.history_id = p.id
						JOIN res_crm_marketing_contact_fase mcf ON mcf.id = mch.contact_fase
						JOIN res_crm_marketing_extra_info mei ON mei.info_id = mch.history_id AND mei.datetime::date = mch.datetime::date
					WHERE mcf.id = 25 AND mei.info LIKE '%lternatief%') sq1
				ON sq1.partner_id = p.id
	JOIN res_users u ON u.id = sq1.author	
ORDER BY sq1.date
-----------------------------
-- opvolging response GIFTEN
-----------------------------
SELECT DISTINCT sq1.* ,
		--aml.account_id,
		aml.date boekingsdatum,
		EXTRACT(year FROM aml.date) jaar,
		EXTRACT(month FROM aml.date) maand,
		--aml.debit, aml.credit,
		(credit - debit) amount,
		REPLACE(REPLACE(REPLACE(aml.name,';',','),chr(10),' '),chr(13), ' ') as description,
		aml.ref,
		--aaa.code,
		COALESCE(aaa1.name,'') dimensie1,
		COALESCE(aaa2.name,'') dimensie2,
		COALESCE(aaa3.name,'') dimensie3,
		COALESCE(COALESCE(aaa3.code,aaa2.code),aaa1.code) AS project_code,
		COALESCE(COALESCE(aaa3.name,aaa2.name),aaa1.name) AS project,
		--p.id p_id,
		p.membership_state huidige_lidmaatschap_status,
		p.membership_nbr lidnummer,
		--'[' || p.id::text || '] ' || p.name as partner,
		--p.name as naam,
		p.first_name as voornaam,
		p.last_name as achternaam,
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
		END gemeente,
		/*p.postbus_nbr postbus,
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
		END AS provincie,*/
		c.name land,
		--p.birthday,
		a5.name partner_naam,
		COALESCE(COALESCE(a2.name,a.name),'onbekend') afdeling,
		/*p.membership_cancel as opzegdatum,
		COALESCE(p.address_state_id,0) adres_status,
		CASE WHEN COALESCE(p.opt_out,'f') = 'f' THEN 'JA' WHEN p.opt_out = 't' THEN 'NEEN' ELSE 'JA' END email_ontvangen,
		CASE WHEN COALESCE(p.opt_out_letter,'f') = 'f' THEN 'JA' WHEN p.opt_out_letter = 't' THEN 'NEEN' ELSE 'JA' END post_ontvangen,
		p.iets_te_verbergen,
		COALESCE(p.deceased,'f') overleden,*/
		p.email,
		/*CASE
			WHEN p.gender = 'M' THEN 'Dhr.'
			WHEN p.gender = 'V' THEN 'Mevr.'
			ELSE pt.shortcut
		END aanspreking,
		p.gender AS geslacht,*/
	 	pct.name,
		aa.code grootboekrek,
		REPLACE(aa.name,';',',') grootboekrek_naam,
		rc.name AS vzw,
		am.name AS boeking,
		'ERP' AS bron
	FROM account_move am
		INNER JOIN account_move_line aml ON aml.move_id = am.id
		INNER JOIN account_account aa ON aa.id = aml.account_id
		LEFT OUTER JOIN res_partner p ON p.id = aml.partner_id
		LEFT OUTER JOIN account_analytic_account aaa1 ON aml.analytic_dimension_1_id = aaa1.id
		LEFT OUTER JOIN account_analytic_account aaa2 ON aml.analytic_dimension_2_id = aaa2.id
		LEFT OUTER JOIN account_analytic_account aaa3 ON aml.analytic_dimension_3_id = aaa3.id
		
		JOIN (SELECT DISTINCT p.id partner_id, mcf.name, mei.info, mch.datetime::date date
				FROM res_partner p
					JOIN res_crm_marketing_contact_history mch ON mch.history_id = p.id
					JOIN res_crm_marketing_contact_fase mcf ON mcf.id = mch.contact_fase
					JOIN res_crm_marketing_extra_info mei ON mei.info_id = mch.history_id AND mei.datetime::date = mch.datetime::date
				WHERE mcf.id = 24 AND mch.datetime::date = '2022-10-31' ) sq1
			ON sq1.partner_id = p.id

		JOIN res_company rc ON aml.company_id = rc.id 
		JOIN res_country c ON p.country_id = c.id
		LEFT OUTER JOIN res_country_city_street ccs ON p.street_id = ccs.id
		LEFT OUTER JOIN res_country_city cc ON p.zip_id = cc.id
		LEFT OUTER JOIN res_partner_title pt ON p.title = pt.id
		--afdeling vs afdeling eigen keuze
		LEFT OUTER JOIN res_partner a ON p.department_id = a.id
		LEFT OUTER JOIN res_partner a2 ON p.department_choice_id = a2.id
		--link naar partner		
		LEFT OUTER JOIN res_partner a5 ON p.relation_partner_id = a5.id
	 	--link naar rechtspersoon
	 	LEFT OUTER JOIN res_partner_corporation_type pct ON pct.id = p.corporation_type_id
	WHERE (aa.code = '732100' OR  aa.code = '732000')
		AND aml.date >= sq1.date
		AND (p.active = 't' OR (p.active = 'f' AND COALESCE(p.deceased,'f') = 't'))	--van de inactieven enkele de overleden contacten meenemen
		--AND p.id = v.testID
	ORDER BY aml.date