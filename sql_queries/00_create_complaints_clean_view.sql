
CREATE OR REPLACE VIEW complaints_clean AS
SELECT
    "Complaint ID" AS complaint_id,
    "Date received"::timestamptz AS date_received,
    "Product" AS product,
    "Sub-product" AS sub_product,
    "Issue" AS issue,
    "Sub-issue" AS sub_issue,
    "Company public response" AS company_public_response,
    "Company" AS company,
    "State" AS state,
    "ZIP code" AS zip_code,
    "Tags" AS tags,
    "Submitted via" AS submitted_via,
    "Date sent to company"::timestamptz AS date_sent_to_company,
    "Company response to consumer" AS company_response_to_consumer,
    "Timely response?" AS timely_response
FROM complaints;
