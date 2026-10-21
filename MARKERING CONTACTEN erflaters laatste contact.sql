SELECT sq2.partner_id, sq2.name, sq2.info, sq2.datum, EXTRACT(YEAR FROM AGE(now()::date,sq2.datum)) jaar_laatste_contact,
		sq2.post, 
		sq2.mail
FROM (
	SELECT sq1.partner_id, sq1.name, sq1.info, MAX(sq1.datum) datum, 
		CASE WHEN dwh_p.geen_post = 'false' THEN 'post ok' ELSE 'geen post' END post, 
		CASE WHEN dwh_p.geen_mail = 'false' THEN 'mail ok' ELSE 'geen mail' END mail,
		ROW_NUMBER() OVER (PARTITION BY sq1.partner_id ORDER BY sq1.datum DESC) AS r
	FROM marketing._m_dwh_partners dwh_p
		JOIN
		(
	--SELECT * FROM (
	--/*
			-- "extra info" selectie
			SELECT p.id partner_id, p.name, mei.id mei_id, mei.info_id mei_info_id, mei.info, COALESCE(mei.datetime::date,'1900-01-01') datum, 
				
				ROW_NUMBER() OVER (PARTITION BY mei.info_id ORDER BY mei.datetime::date DESC) AS r
			FROM res_partner p
				JOIN res_crm_marketing_extra_info mei ON mei.info_id = p.id
			WHERE mei.partner_type = 2 -- "erflater"
				AND p.active
						
			UNION ALL--*/
			
			-- "fase" selectie
			SELECT p.id partner_id, p.name, mch.id mch_id, mch.history_id mch_history_id, mcf.name status, COALESCE(mch.datetime::date,'1900-01-01') datum,  
				--EXTRACT(YEAR FROM AGE(now()::date,mch.datetime)) jaar,
				ROW_NUMBER() OVER (PARTITION BY mch.history_id ORDER BY mch.datetime::date DESC) AS r
			FROM res_partner p
				JOIN res_crm_marketing_contact_history mch ON mch.history_id = p.id
				JOIN res_crm_marketing_contact_fase mcf ON mcf.id = mch.contact_fase
			WHERE mch.partner_type = 2 -- "erflater" 
				AND NOT(mcf.name = 'LEG_verzending')
				AND p.active
	
		) sq1
		ON sq1.partner_id = dwh_p.partner_id
	WHERE sq1.r = 1
		AND sq1.datum > '1900-01-01'
		AND dwh_p.overleden = 'false'
		AND dwh_p.nooit_contact = 'false'
		
		--AND dwh_p.partner_id = 164648 -- test_ID
	GROUP BY sq1. partner_id, sq1.name, sq1.info, sq1.datum
		, dwh_p.geen_post, dwh_p.geen_mail
	ORDER BY sq1.partner_id
	) sq2
WHERE sq2.r = 1



