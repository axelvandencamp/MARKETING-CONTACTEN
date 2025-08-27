-- CONTROLE partner_id's originele verzendlijst tov in marketing_contacten geregistreerde deelnemers aan actie
SELECT sq1.partner_id vzl_partner_id, sq1.name vzl_name, sq1.date vzl_datum, sq1.info vzl_info,
	sq2.partner_id r_partner_id, COALESCE(sq2.name,'') r_name, sq2.date r_datum, 
	REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(COALESCE(sq2.info,''),chr(9),''),chr(10),''),chr(11),''),chr(12),''),chr(13),'') r_info
FROM
	(
	SELECT DISTINCT p.id partner_id, mcf.name, mei.info, mch.datetime::date date
	FROM res_partner p
		JOIN res_crm_marketing_contact_history mch ON mch.history_id = p.id
		JOIN res_crm_marketing_contact_fase mcf ON mcf.id = mch.contact_fase
		JOIN res_crm_marketing_extra_info mei ON mei.info_id = mch.history_id AND mei.datetime::date = mch.datetime::date
	WHERE mcf.id = 1039 AND mei.info LIKE '%#24184'
	) SQ1 -- partner_id's uit orig. verzendlijst
	LEFT OUTER JOIN
	(
	SELECT DISTINCT p.id partner_id, mcf.name, mei.info, mch.datetime::date date
	FROM res_partner p
		JOIN res_crm_marketing_contact_history mch ON mch.history_id = p.id
		JOIN res_crm_marketing_contact_fase mcf ON mcf.id = mch.contact_fase
		JOIN res_crm_marketing_extra_info mei ON mei.info_id = mch.history_id AND mei.datetime::date = mch.datetime::date
	WHERE mcf.id = 1039 AND NOT(mei.info LIKE '%#24184')
	) SQ2 -- partner_id's in marketing_contacten geregistreerd als deelnemer aan de actie
	ON SQ1.partner_id = SQ2.partner_id