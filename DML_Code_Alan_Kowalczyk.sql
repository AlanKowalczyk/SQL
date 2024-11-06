-----------------------------------------
-- Created on 17 Apr 2024              --
-- Last modification 20 Apr 2024 by AK --
-- author Alan Kowalczyk               --
-----------------------------------------

-- deleting from tables for development/debugging purposes
DELETE FROM employees;
DELETE FROM managers;
DELETE FROM dependents;
DELETE FROM departments;
DELETE FROM projects;
DELETE FROM locations;
DELETE FROM project_assigmnents;
DELETE FROM customers;
DELETE FROM products;
DELETE FROM orders;
DELETE FROM warehouses;
DELETE FROM inventories;

-- inserting data from helpers files: people.csv and sample_products_csv into tables, and adding random data in order to populates tables
-- Inserting data into employees table
INSERT INTO employees(first_name, last_name, nino, address, postcode, salary, date_of_birth, phone, email, start_date, end_date, department_id, is_supervisor)
SELECT 
    p.first_name,
    p.last_name,
    SUBSTR(UPPER(DBMS_RANDOM.STRING('A', 2)) || CEIL(DBMS_RANDOM.VALUE(100000, 999999)) || UPPER(DBMS_RANDOM.STRING('A', 1)), 1, 9) AS nino, 
    p.address,
    p.postcode,
    ROUND(DBMS_RANDOM.VALUE(26000, 100000), 2) AS salary, -- Random salary between 26000 and 100000 with 2 decimal places
    TRUNC(SYSDATE - DBMS_RANDOM.VALUE(365*18, 365*67)) AS date_of_birth, -- Random date of birth between 18 and 67 years ago
    ROUND(DBMS_RANDOM.VALUE(7000000000, 7999999999)),
    p.email,
    TRUNC(SYSDATE - DBMS_RANDOM.VALUE(0, 365*24)) AS start_date, -- Random start date between now and 24 years ago
    CASE WHEN DBMS_RANDOM.VALUE(0, 1) > 0.05 THEN NULL ELSE TRUNC(SYSDATE - DBMS_RANDOM.VALUE(1, 365)) END AS end_date, -- Random end_date in 5% cases
    CEIL(DBMS_RANDOM.VALUE(1, 6)) AS department_id, -- Random department_id between 1 and 6
    CASE WHEN DBMS_RANDOM.VALUE(0, 1) < 0.2 THEN 'Y' ELSE 'N' END AS is_supervisor --20% of employees are supervisors
FROM 
    people p -- from people table up to 100 dependats, 101-400 employees, 401-1000 - customers
WHERE id BETWEEN 101 AND 400;  

-- Updating supervisor_id for non-supervisor employees
UPDATE employees e
SET supervisor_id = ROUND(DBMS_RANDOM.VALUE(10000, 12000))
WHERE is_supervisor = 'N';

-- Populating managers table with six rows, as 6 departmets exists
BEGIN
    FOR i IN 1..6 LOOP
        INSERT INTO managers (start_date, employee_id)
        VALUES (
            TRUNC(SYSDATE - DBMS_RANDOM.VALUE(0, 24*365)), -- Random start date within the past 24 years
            (SELECT id FROM employees ORDER BY DBMS_RANDOM.VALUE() FETCH FIRST 1 ROWS ONLY) -- Selecting a single random employee ID
        );
    END LOOP;
END;
/

--dependents
INSERT INTO dependents (employee_id, first_name, date_of_birth, relationship)
SELECT 
    e.id AS employee_id,
    p.first_name,
    TRUNC(SYSDATE - DBMS_RANDOM.VALUE(0, 365*1000)) AS date_of_birth, -- Random date of birth within the past 100 years
    CASE MOD(ROWNUM, 3) --diffrent kind of relationship in table
        WHEN 1 THEN 'Child'
        WHEN 2 THEN 'Spouse'
        ELSE 'Parent'
    END AS relationship 
FROM 
    (SELECT id, ROW_NUMBER() OVER (ORDER BY DBMS_RANDOM.VALUE()) AS rn FROM employees) e,
    (SELECT first_name, ROW_NUMBER() OVER (ORDER BY id) AS rn FROM people) p
WHERE 
    e.rn = p.rn
    AND ROWNUM <= 100;

--departments
DECLARE
    v_manager_id NUMBER;
BEGIN
    FOR i IN 1..6 LOOP
        SELECT id INTO v_manager_id
        FROM (
            SELECT id, ROW_NUMBER() OVER (ORDER BY id) AS rn
            FROM managers
        ) 
        WHERE rn = i;
        
        INSERT INTO departments (department_name, manager_id)
        VALUES ('department_' || i, v_manager_id);
    END LOOP;
END;
/

--locations
DECLARE
    v_department_id NUMBER;
BEGIN
    FOR i IN 1..6 LOOP
        SELECT id INTO v_department_id
        FROM (
            SELECT id, ROW_NUMBER() OVER (ORDER BY id) AS rn
            FROM departments
        ) 
        WHERE rn = i;
        
        INSERT INTO locations (address, postcode, department_id)
        VALUES (
           (SELECT address FROM people WHERE id = i + 10), --addresses from first 100 for locations, and warehouses
           (SELECT postcode FROM people WHERE id = i + 10),
            v_department_id
        );
    END LOOP;
END;
/

--projects
DECLARE
    v_location_id NUMBER;
BEGIN
    FOR i IN 1..200 LOOP
        SELECT id INTO v_location_id
        FROM (
            SELECT id FROM locations ORDER BY DBMS_RANDOM.VALUE()
        )
        WHERE ROWNUM = 1;
        INSERT INTO projects (projects_name, location_id)
        VALUES (
            'Project_' || i,
            v_location_id
        );
    END LOOP;
END;
/

--project_assigmnets
DECLARE
    v_employee_id NUMBER;
    v_hours_worked NUMBER;
BEGIN
    FOR i IN 1..200 LOOP
        SELECT id INTO v_employee_id
        FROM (
            SELECT id FROM employees ORDER BY DBMS_RANDOM.VALUE()
        )
        WHERE ROWNUM = 1;
        v_hours_worked := ROUND(DBMS_RANDOM.VALUE(1, 40) * 4) / 4;
        INSERT INTO project_assigmnents (id, employee_id, project_id, hours_worked)
        VALUES (
            i, -- Using loop index as ID
            v_employee_id, -- Random employee ID
            i, -- Using loop index as project ID
            v_hours_worked -- Rounded hours worked
        );
    END LOOP;
END;
/

--customers
DECLARE
    v_employee_id NUMBER;
BEGIN
    FOR i IN 1..600 LOOP
        SELECT id INTO v_employee_id
        FROM (
            SELECT id FROM employees ORDER BY DBMS_RANDOM.VALUE()
        )
        WHERE ROWNUM = 1;
        INSERT INTO customers (first_name, last_name, address, postcode, date_of_birth, phone, email, employee_id)
        VALUES (
            (SELECT first_name FROM people WHERE id = i + 400), --up to 100 dependats, 101-400 employees, 401-1000 - customers
            (SELECT last_name FROM people WHERE id = i + 400),
            (SELECT address FROM people WHERE id = i + 400),
            (SELECT postcode FROM people WHERE id = i + 400),
            TRUNC(SYSDATE - DBMS_RANDOM.VALUE(365*18, 365*67)),
            ROUND(DBMS_RANDOM.VALUE(7000000000, 7999999999)),
            (SELECT email FROM people WHERE id = i + 400),
            v_employee_id
        );
    END LOOP;
END;
/

--products
INSERT INTO products (product_name, price, shipment_weight)
SELECT productname, price, weight_kg
FROM SAMPLE_PRODUCTS;

--orders
DECLARE
    v_customer_id NUMBER;
    v_product_id NUMBER;
    v_quantity NUMBER;
    v_order_date DATE;
    v_max_customer_id NUMBER;
    v_max_product_id NUMBER;
BEGIN
    SELECT MAX(id) INTO v_max_customer_id FROM customers;
    SELECT MAX(id) INTO v_max_product_id FROM products;
    FOR i IN 1..10000 LOOP
        v_customer_id := TRUNC(DBMS_RANDOM.VALUE(1, v_max_customer_id));
        v_product_id := TRUNC(DBMS_RANDOM.VALUE(1, v_max_product_id));
        v_quantity := TRUNC(DBMS_RANDOM.VALUE(1, 100));
        v_order_date := TRUNC(SYSDATE) - TRUNC(DBMS_RANDOM.VALUE(0, 365)); 
        INSERT INTO orders (customer_id, product_id, quantity, order_date)
        VALUES (v_customer_id, v_product_id, v_quantity, v_order_date);
    END LOOP;
END;
/

--warehouses
BEGIN
    FOR i IN 1..3 LOOP
        INSERT INTO warehouses (address, postcode)
        VALUES (
            (SELECT address FROM people WHERE id = i + 50), --addresses from first 100 for locations, and warehouses
            (SELECT postcode FROM people WHERE id = i + 50)
        );
    END LOOP;
END;
/

--inventories
DECLARE
    v_quantity NUMBER;
    v_inventory_date DATE;
    v_warehouse_id NUMBER; 
BEGIN
    FOR product_rec IN (SELECT id FROM products) LOOP
        v_quantity := TRUNC(DBMS_RANDOM.VALUE(0, 100000));
        v_inventory_date := TRUNC(SYSDATE) - TRUNC(DBMS_RANDOM.VALUE(1, 365));
        v_warehouse_id := TRUNC(DBMS_RANDOM.VALUE(1, 3)); 
        INSERT INTO inventories (warehouse_id, product_id, quantity, inventory_date)
        VALUES (v_warehouse_id, product_rec.id, v_quantity, v_inventory_date);
    END LOOP;
END;
/
