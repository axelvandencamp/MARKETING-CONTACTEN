--=================================================================
--SET VARIABLES
DROP TABLE IF EXISTS _AV_myvar;
CREATE TEMP TABLE _AV_myvar 
	(marketingcontacttype text,
	 startdatumdefmd date, einddatumdefmd date
	 );

INSERT INTO _AV_myvar VALUES('Schenker: major donor', now()::date, now()::date
				);
UPDATE _AV_myvar SET startdatumdefmd = startdatumdefmd - interval '3 year'	;			
SELECT * FROM _AV_myvar;
--====================================================================
SELECT p.id, mptr.*, mpt.*, mei.*
FROM _AV_myvar v, res_partner p
	--marketing contacten info
	LEFT OUTER JOIN crm_marketing_partner_type_rel mptr ON mptr.partner_type_id = p.id
	LEFT OUTER JOIN res_crm_marketing_partner_type mpt ON mpt.id = mptr.name
	LEFT OUTER JOIN res_crm_marketing_extra_info mei ON mei.info_id = p.id
WHERE --LOWER(mei.info) LIKE '%onze natuur%' AND LOWER(mei.info) LIKE '%bevestiging%'
	-- enkel selectie van effectieve Marketing Contacten om Contact Personen hier uit te sluiten
	(p.id IN (SELECT partner_type_id FROM crm_marketing_partner_type_rel))
	AND mpt.name = v.marketingcontacttype
--========================
-- Major Donor - prospect
--========================
SELECT p.id, p.name, mptr.name, mpt.id, mpt.name, mch.partner_type, mcf.id, mcf.name, mch.datetime::date
FROM _AV_myvar v, res_partner p
	--marketing contacten info
	JOIN crm_marketing_partner_type_rel mptr ON mptr.partner_type_id = p.id
	JOIN res_crm_marketing_partner_type mpt ON mpt.id = mptr.name
	JOIN res_crm_marketing_contact_history mch ON mpt.id = mch.partner_type AND mch.history_id = p.id
	JOIN res_crm_marketing_contact_fase mcf ON mch.contact_fase = mcf.id
WHERE mpt.name = v.marketingcontacttype
	AND mcf.name = 'Major Donor - prospect'
--==========================
-- temp Giften
--==========================
DROP TABLE IF EXISTS marketing._temp_giften;
CREATE TABLE marketing._temp_giften (partner_id integer, jaar text, amount numeric);
INSERT INTO marketing._temp_giften (SELECT partner_id, jaar, amount FROM _AV_myvar v, marketing._crm_giften ( NULL,  v.startdatumdefmd  ,  v.einddatumdefmd ));
--==========================
-- Major Donors volgens definitie uit giften: #16572
--==========================


