-- CONTROLE partner_id's originele verzendlijst tov in marketing_contacten geregistreerde deelnemers aan actie
SELECT *
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