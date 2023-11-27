#step 1 - diabetes counts#
select condition_occurrence.condition_concept_id, concept.concept_name as condition_name, count(distinct condition_occurrence.person_id) as disease_count
from condition_occurrence, concept
where condition_occurrence.condition_concept_id = concept.concept_id 
and
concept_name like '%diabete%'
group by condition_occurrence.condition_concept_id, concept.concept_name 
having count(distinct condition_occurrence.person_id) 
order by disease_count DESC;


#step 2 drug list - need to identify DM drugs#
select drug_exposure.drug_concept_id, concept.concept_name as drug_name, count(distinct drug_exposure.person_id) as prescription_count
from drug_exposure, concept
where drug_exposure.drug_concept_id = concept.concept_id
group by drug_exposure.drug_concept_id, concept.concept_name 
having count(distinct drug_exposure.person_id) 
order by prescription_count DESC;

#step 3 Lab tests#
select measurement.measurement_concept_id, concept.concept_name as measurement_name, count(distinct measurement.person_id) as measurement_count
from measurement, concept
where measurement.measurement_concept_id = concept.concept_id
group by measurement.measurement_concept_id, concept.concept_name
having count(distinct measurement.person_id)
order by measurement_count DESC;

#step 4 OPT- Procedures#
select procedure_occurrence.procedure_concept_id, concept.concept_name as procedure_name, count(distinct procedure_occurrence.person_id) as procedure_count
from procedure_occurrence, concept
where procedure_occurrence.procedure_concept_id = concept.concept_id
group by procedure_occurrence.procedure_concept_id, concept.concept_name 
having count(distinct procedure_occurrence.person_id)
order by procedure_count DESC;

#OPT- Comorbidities list#
select condition_occurrence.condition_concept_id, concept.concept_name as condition_name, count(distinct condition_occurrence.person_id) as disease_count
from condition_occurrence, concept
where condition_occurrence.condition_concept_id = concept.concept_id 
group by condition_occurrence.condition_concept_id, concept.concept_name 
having count(distinct condition_occurrence.person_id) 
order by disease_count DESC;


