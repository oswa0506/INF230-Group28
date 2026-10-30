-- =========================================
-- D.2 Data definition language (create table)
-- =========================================
-- Rekkefoelge: tabeller som andre tabeller peker paa (FK) maa lages foerst.
-- Foerst de tre "hovedtabellene", saa comprehensibility, saa koblingstabellene.
 
-- Sletter gamle tabeller slik at skriptet kan kjoeres flere ganger
-- (i omvendt rekkefoelge, fordi koblingstabellene peker paa hovedtabellene).
DROP TABLE IF EXISTS related_to;
DROP TABLE IF EXISTS explanation_concept;
DROP TABLE IF EXISTS explanation_audience;
DROP TABLE IF EXISTS comprehensibility;
DROP TABLE IF EXISTS concept;
DROP TABLE IF EXISTS audience;
DROP TABLE IF EXISTS explanation;
 
-- Hovedtabell: en rad per forklaring
CREATE TABLE explanation (
    explanation_id    VARCHAR(20)  PRIMARY KEY,
    description       VARCHAR(500) NOT NULL,
    explanation_type  VARCHAR(30)  NOT NULL
        CHECK (explanation_type IN ('Counterfactual', 'Causal',
                                    'Teleological', 'DeductiveNomological'))
);
 
-- En rad per maalgruppe (publikum)
CREATE TABLE audience (
    audience_id    VARCHAR(20)  PRIMARY KEY,
    label          VARCHAR(100),
    audience_name  VARCHAR(100) NOT NULL
);
 
-- En rad per begrep som kan undervises
CREATE TABLE concept (
    concept_id    VARCHAR(20)  PRIMARY KEY,
    label         VARCHAR(100),
    concept_name  VARCHAR(100) NOT NULL
);
 
-- 1:N - hver egenskap hoerer til noeyaktig en forklaring (hasProperty)
CREATE TABLE comprehensibility (
    property_id     VARCHAR(20)  PRIMARY KEY,
    label           VARCHAR(100),
    rating_label    VARCHAR(50)  NOT NULL,
    explanation_id  VARCHAR(20)  NOT NULL,
    FOREIGN KEY (explanation_id) REFERENCES explanation(explanation_id)
);
 
-- N:M - isSuitableForAudience
-- Sammensatt primaernøkkel: samme par kan ikke lagres to ganger.
CREATE TABLE explanation_audience (
    explanation_id  VARCHAR(20),
    audience_id     VARCHAR(20),
    PRIMARY KEY (explanation_id, audience_id),
    FOREIGN KEY (explanation_id) REFERENCES explanation(explanation_id),
    FOREIGN KEY (audience_id)    REFERENCES audience(audience_id)
);
 
-- N:M - isSuitableForTeaching
CREATE TABLE explanation_concept (
    explanation_id  VARCHAR(20),
    concept_id      VARCHAR(20),
    PRIMARY KEY (explanation_id, concept_id),
    FOREIGN KEY (explanation_id) REFERENCES explanation(explanation_id),
    FOREIGN KEY (concept_id)     REFERENCES concept(concept_id)
);
 
-- N:M fra explanation til seg selv - relatedTo (symmetrisk)
-- CHECK sikrer at hvert par bare lagres en gang (minste id foerst),
-- og at en forklaring ikke kan vaere relatert til seg selv.
CREATE TABLE related_to (
    explanation_id_1  VARCHAR(20),
    explanation_id_2  VARCHAR(20),
    PRIMARY KEY (explanation_id_1, explanation_id_2),
    FOREIGN KEY (explanation_id_1) REFERENCES explanation(explanation_id),
    FOREIGN KEY (explanation_id_2) REFERENCES explanation(explanation_id),
    CHECK (explanation_id_1 < explanation_id_2)
);
