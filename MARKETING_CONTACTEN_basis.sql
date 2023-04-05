SELECT p.id, tr.* FROM crm_marketing_partner_type_rel tr
	JOIN res_partner p ON p.id = tr.partner_type_id
WHERE p.active = false AND tr.name = 2
SELECT * FROM crm_marketing_partner_type_rel
SELECT * FROM res_crm_marketing_partner_type
-- SELECT id, name FROM res_crm_marketing_partner_type
SELECT * FROM res_crm_marketing_contact_history
SELECT * FROM res_crm_marketing_contact_fase
--SELECT * FROM crm_marketing_sector_rel
SELECT * FROM res_crm_marketing_extra_info -- WHERE info_id = 21362
SELECT * FROM res_crm_marketing_sector

SELECT * FROM res_users u WHERE u.login like 'ward%'

SELECT id, name FROM res_crm_marketing_partner_type


SELECT * FROM res_crm_marketing_contact_history mch WHERE mch.partner_type = 2

SELECT * FROM
--SELECT DISTINCT(id) FROM
	(SELECT p.id, p.name, mptr.name p_type_id, mpt.name partner_type, 'status' _type, mch.datetime::date _date, COALESCE(mcf.name,'n/a') info
	FROM res_partner p
		JOIN crm_marketing_partner_type_rel mptr ON mptr.partner_type_id = p.id
		JOIN res_crm_marketing_partner_type mpt ON mpt.id = mptr.name
		LEFT OUTER JOIN res_crm_marketing_contact_history mch ON mch.history_id = p.id
		LEFT OUTER JOIN res_crm_marketing_contact_fase mcf ON mcf.id = mch.contact_fase
	 	--JOIN res_users u ON u.id = mch.write_uid AND mch.write_uid = 315 AND mch.write_date >= '2023-03-08'  -- aanpassing obv user_id
	WHERE mch.author = 548 AND mch.write_date >= '2022-03-09' -- aanpassing obv auteur
	UNION ALL
	SELECT p.id, p.name, mptr.name p_type_id, mpt.name partner_type, 'info' _type, mei.datetime::date _date, 
	 	REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(COALESCE(mei.info,'n/a'),chr(9),';'),chr(10),';'),chr(11),';'),chr(12),';'),chr(13),';') info
	FROM res_partner p
		JOIN crm_marketing_partner_type_rel mptr ON mptr.partner_type_id = p.id
		JOIN res_crm_marketing_partner_type mpt ON mpt.id = mptr.name
		LEFT OUTER JOIN res_crm_marketing_extra_info mei ON mei.info_id = p.id
		--JOIN res_users U ON u.id = mei.write_uid AND mei.write_uid = 315 AND mei.write_date >= '2023-03-08'  -- aanpassing obv user_id
	WHERE mei.author = 548 AND mei.write_date >= '2022-03-09' -- aanpassing obv auteur
	) SQ1
	JOIN marketing._crm_partnerinfo() SQ2 ON SQ2.partner_id = SQ1.id
WHERE NOT(info = 'n/a') --AND p_type_id = 1
ORDER BY SQ1.id, SQ1._date DESC	

-- ophalen verzendlijst --
SELECT p.id, p.name, mptr.name p_type_id, mpt.name partner_type, mch.datetime::date _date, mcf.name status,
	SQ1.*
FROM res_partner p
	JOIN crm_marketing_partner_type_rel mptr ON mptr.partner_type_id = p.id
	JOIN res_crm_marketing_partner_type mpt ON mpt.id = mptr.name
	LEFT OUTER JOIN res_crm_marketing_contact_history mch ON mch.history_id = p.id
	LEFT OUTER JOIN res_crm_marketing_contact_fase mcf ON mcf.id = mch.contact_fase
	JOIN marketing._crm_partnerinfo() SQ1 ON SQ1.partner_id = p.id	
WHERE mptr.name = 1