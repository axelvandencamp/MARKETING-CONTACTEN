SELECT sq1.*, p.id, p.name, p.membership_state, p.active,
	p.membership_start Lidmaatschap_startdatum, 
	p.membership_stop Lidmaatschap_einddatum,  
	p.membership_pay_date betaaldatum,
	p.membership_renewal_date hernieuwingsdatum,
	p.membership_end recentste_einddatum_lidmaatschap,
	p.membership_cancel membership_cancel
FROM res_partner p
	JOIN (SELECT DISTINCT p.id partner_id, mcf.name fase, mei.info, u.login, mch.datetime::date datum,
					ROW_NUMBER() OVER (PARTITION BY p.id ORDER BY mch.datetime ASC) AS r
					FROM res_partner p
						JOIN res_crm_marketing_contact_history mch ON mch.history_id = p.id
						JOIN res_crm_marketing_contact_fase mcf ON mcf.id = mch.contact_fase
						JOIN res_crm_marketing_extra_info mei ON mei.info_id = mch.history_id AND mei.datetime::date = mch.datetime::date
						JOIN res_users u ON u.id = mei.create_uid
					WHERE mcf.id = 33 /*AND mei.info LIKE '%#16483'*/) sq1
				ON sq1.partner_id = p.id
WHERE sq1.datum > '2025-01-01'	



