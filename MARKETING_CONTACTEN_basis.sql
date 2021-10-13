SELECT * FROM crm_marketing_partner_type_rel
SELECT * FROM res_crm_marketing_partner_type
SELECT * FROM res_crm_marketing_contact_history
SELECT * FROM res_crm_marketing_contact_fase
--SELECT * FROM crm_marketing_sector_rel
SELECT * FROM res_crm_marketing_extra_info -- WHERE info_id = 21362
SELECT * FROM res_crm_marketing_sector


SELECT * FROM res_crm_marketing_contact_history mch WHERE mch.partner_type = 2

SELECT * FROM
	(SELECT p.id, mpt.name, 'status' _type, mch.datetime::date _date, mcf.name
	FROM res_partner p
		JOIN crm_marketing_partner_type_rel mptr ON mptr.partner_type_id = p.id
		JOIN res_crm_marketing_partner_type mpt ON mpt.id = mptr.name
		LEFT OUTER JOIN res_crm_marketing_contact_history mch ON mch.history_id = p.id
		LEFT OUTER JOIN res_crm_marketing_contact_fase mcf ON mcf.id = mch.contact_fase
	UNION ALL
	SELECT p.id, mpt.name, 'info' _type, mei.datetime::date _date, mei.info
	FROM res_partner p
		JOIN crm_marketing_partner_type_rel mptr ON mptr.partner_type_id = p.id
		JOIN res_crm_marketing_partner_type mpt ON mpt.id = mptr.name
		LEFT OUTER JOIN res_crm_marketing_extra_info mei ON mei.info_id = p.id) SQ1
ORDER BY SQ1.id, SQ1._date DESC	
	