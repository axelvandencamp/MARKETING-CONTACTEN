--=================================================================
--SET VARIABLES
DROP TABLE IF EXISTS _AV_myvar;
CREATE TEMP TABLE _AV_myvar 
	(verzending NUMERIC, lijst TEXT, project_code TEXT, startdatum DATE, einddatum DATE
	 );

INSERT INTO _AV_myvar VALUES(24,	--verzending
				'mail Rode Dopheidereservaat #16456 ',	--lijst
				'WVL-3512-5513',  -- project_code
				now()::date, -- startdatum
				now()::date  -- einddatum
				);
				
UPDATE _AV_myvar
SET startdatum =
	(SELECT DISTINCT mei.datetime::date
	FROM _AV_myvar v, res_partner p
		JOIN res_crm_marketing_contact_history mch ON mch.history_id = p.id
		JOIN res_crm_marketing_contact_fase mcf ON mcf.id = mch.contact_fase
		JOIN res_crm_marketing_extra_info mei ON mei.info_id = mch.history_id AND mei.datetime::date = mch.datetime::date
	WHERE mcf.id = v.verzending AND mei.info = v.lijst);

SELECT * FROM _AV_myvar;
--====================================================================
SELECT DISTINCT sq1.* ,
		--aml.account_id,
		aml.date boekingsdatum,
		(credit - debit) amount,
		REPLACE(REPLACE(REPLACE(aml.name,';',','),chr(10),' '),chr(13), ' ') as description,
		aml.ref,
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

		c.name land,
		--p.birthday,
		a5.name partner_naam,
		COALESCE(COALESCE(a2.name,a.name),'onbekend') afdeling,
		p.email,
	 	pct.name,
		aa.code grootboekrek,
		REPLACE(aa.name,';',',') grootboekrek_naam,
		rc.name AS vzw,
		am.name AS boeking,
		'ERP' AS bron,
		dp.*
	FROM _AV_myvar v, account_move am
		INNER JOIN account_move_line aml ON aml.move_id = am.id
		INNER JOIN account_account aa ON aa.id = aml.account_id
		LEFT OUTER JOIN res_partner p ON p.id = aml.partner_id
		LEFT OUTER JOIN account_analytic_account aaa1 ON aml.analytic_dimension_1_id = aaa1.id
		LEFT OUTER JOIN account_analytic_account aaa2 ON aml.analytic_dimension_2_id = aaa2.id
		LEFT OUTER JOIN account_analytic_account aaa3 ON aml.analytic_dimension_3_id = aaa3.id
		
		JOIN (SELECT DISTINCT p.id partner_id, mcf.name, mei.info, mch.datetime::date date
				FROM _AV_myvar v, res_partner p
					JOIN res_crm_marketing_contact_history mch ON mch.history_id = p.id
					JOIN res_crm_marketing_contact_fase mcf ON mcf.id = mch.contact_fase
					JOIN res_crm_marketing_extra_info mei ON mei.info_id = mch.history_id AND mei.datetime::date = mch.datetime::date
				WHERE mcf.id = v.verzending AND mei.info = v.lijst) sq1
			ON sq1.partner_id = p.id

		JOIN marketing._m_dwh_donateursprofiel dp ON dp.partner_id = p.id
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
		AND aml.date >= v.startdatum
		AND COALESCE(COALESCE(aaa3.code,aaa2.code),aaa1.code) = v.project_code
		AND (p.active = 't' OR (p.active = 'f' AND COALESCE(p.deceased,'f') = 't'))	--van de inactieven enkele de overleden contacten meenemen
		--AND p.id = v.testID
	ORDER BY aml.date