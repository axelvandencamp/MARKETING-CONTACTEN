SELECT p.id, p.name, mpt.name contact_type, mch.datetime::date, mch.create_date, mcf.name fase,
    p.first_name as voornaam,
    p.last_name as naam,
    COALESCE(p.email,p.email_work) email,
    CASE
        WHEN c.id = 21 AND p.crab_used = 'true' THEN ccs.name
        ELSE p.street
    END straat,
    CASE
        WHEN c.id = 21 AND p.crab_used = 'true' THEN p.street_nbr ELSE ''
    END huisnummer, 
    p.street_bus busnummer,
    CASE
        WHEN c.id = 21 AND p.crab_used = 'true' THEN cc.zip
        ELSE p.zip
    END postcode,
    CASE 
        WHEN c.id = 21 THEN cc.name ELSE p.city 
    END gemeente,
    _crm_land(c.id) land,
    CASE
        WHEN COALESCE(p.opt_out_letter,'f') = 'f' THEN 0 ELSE 1
    END wenst_geen_post_van_NP,
    CASE
        WHEN COALESCE(p.opt_out,'f') = 'f' THEN 0 ELSE 1
    END wenst_geen_email_van_NP,
    p.iets_te_verbergen nooit_contacteren,
    p.deceased overleden,
	dp.major_donor,
	dp.schenker_grond
FROM res_partner p JOIN
    (SELECT mch_id, mch_history_id FROM
        (SELECT mch.id mch_id, mch.history_id mch_history_id, ROW_NUMBER() OVER (PARTITION BY mch.history_id ORDER BY mch.datetime::date DESC) AS r
        FROM res_crm_marketing_contact_history mch
        WHERE mch.partner_type = 2 -- "erflater" 
            /*AND mch.history_id = 17799*/) sq2
    WHERE sq2.r = 1) sq1 ON sq1.mch_history_id = p.id
    JOIN res_crm_marketing_contact_history mch ON mch.id = sq1.mch_id
    JOIN res_crm_marketing_contact_fase mcf ON mcf.id = mch.contact_fase
    JOIN res_crm_marketing_partner_type mpt ON mpt.id = mch.partner_type
	--partner info
	JOIN marketing._m_dwh_partners dp ON dp.partner_id = p.id
    --land, straat, gemeente info
    JOIN res_country c ON p.country_id = c.id
    LEFT OUTER JOIN res_country_city_street ccs ON p.street_id = ccs.id
    LEFT OUTER JOIN res_country_city cc ON p.zip_id = cc.id
WHERE p.active -- mcf.id = 7
    AND NOT(mcf.id IN (9,10))
    AND cc.zip IN ( LIJST POSTCODES )



SELECT * FROM marketing._m_dwh_partners LIMIT 1000