-----------------------------------------
-- Created on 30 Mar 2024              --
-- Last modification 20 Apr 2024 by AK --
-- author Alan Kowalczyk               --
-----------------------------------------


-- dropping tables for development/debugging purposes
DROP TABLE employees CASCADE CONSTRAINTS;
DROP TABLE managers CASCADE CONSTRAINTS;
DROP TABLE dependents CASCADE CONSTRAINTS;
DROP TABLE departments CASCADE CONSTRAINTS;
DROP TABLE projects CASCADE CONSTRAINTS;
DROP TABLE locations CASCADE CONSTRAINTS;
DROP TABLE project_assigmnents CASCADE CONSTRAINTS;
DROP TABLE customers CASCADE CONSTRAINTS;
DROP TABLE products CASCADE CONSTRAINTS;
DROP TABLE orders CASCADE CONSTRAINTS;
DROP TABLE warehouses CASCADE CONSTRAINTS;
DROP TABLE inventories CASCADE CONSTRAINTS;

-- creating tables with all columns/attributes
CREATE TABLE employees (
   id NUMBER GENERATED BY DEFAULT ON NULL AS IDENTITY PRIMARY KEY,
   first_name VARCHAR2(50) NOT NULL,
   last_name VARCHAR2(50) NOT NULL,
   nino VARCHAR2(9) NOT NULL,
   address VARCHAR2(200) NOT NULL,
   postcode VARCHAR2(20) NOT NULL,
   salary NUMBER(8,2) NOT NULL,
   date_of_birth DATE NOT NULL,
   phone NUMBER,
   email VARCHAR2(50),
   start_date DATE NOT NULL,
   end_date DATE,
   department_id NUMBER,
   is_supervisor CHAR(1) NOT NULL,
   supervisor_id NUMBER
);

CREATE TABLE managers (
   id NUMBER GENERATED BY DEFAULT ON NULL AS IDENTITY PRIMARY KEY,
   start_date DATE NOT NULL,
   end_date DATE,
   employee_id NUMBER NOT NULL
);

CREATE TABLE dependents (
   id NUMBER GENERATED BY DEFAULT ON NULL AS IDENTITY PRIMARY KEY,
   employee_id NUMBER NOT NULL,
   first_name VARCHAR2(50) NOT NULL,
   date_of_birth DATE NOT NULL,
   relationship VARCHAR2(50) NOT NULL
);

CREATE TABLE departments (
   id NUMBER GENERATED BY DEFAULT ON NULL AS IDENTITY PRIMARY KEY,
   department_name VARCHAR2(50) NOT NULL,
   manager_id NUMBER NOT NULL
);

CREATE TABLE locations (
   id NUMBER GENERATED BY DEFAULT ON NULL AS IDENTITY PRIMARY KEY,
    address VARCHAR2(200) NOT NULL,
    postcode VARCHAR2(20) NOT NULL,
    department_id NUMBER NOT NULL
);

CREATE TABLE projects (
   id NUMBER GENERATED BY DEFAULT ON NULL AS IDENTITY PRIMARY KEY,
   projects_name VARCHAR2(50) NOT NULL,
   location_id NUMBER NOT NULL
);

CREATE TABLE project_assigmnents(
   id NUMBER GENERATED BY DEFAULT ON NULL AS IDENTITY,
   employee_id NUMBER NOT NULL,
   project_id NUMBER NOT NULL,
   hours_worked NUMBER(8,2) NOT NULL
);

CREATE TABLE customers (
    id NUMBER GENERATED BY DEFAULT ON NULL AS IDENTITY PRIMARY KEY,
    first_name VARCHAR2(50) NOT NULL,
    last_name VARCHAR2(50) NOT NULL,
    address VARCHAR2(200) NOT NULL,
    postcode VARCHAR2(20) NOT NULL,
    date_of_birth DATE NOT NULL,
    phone NUMBER,
    email VARCHAR2(50),
    employee_id NUMBER NOT NULL
);

CREATE TABLE products (
    id NUMBER GENERATED BY DEFAULT ON NULL AS IDENTITY PRIMARY KEY,
    product_name VARCHAR2(400) NOT NULL,
    price NUMBER(8,2) NOT NULL,
    shipment_weight NUMBER(8,2) NOT NULL
);

CREATE TABLE orders(
    id NUMBER GENERATED BY DEFAULT ON NULL AS IDENTITY PRIMARY KEY,
    customer_id NUMBER NOT NULL,
    product_id NUMBER NOT NULL,
    quantity NUMBER NOT NULL,
    order_date DATE NOT NULL
);

CREATE TABLE warehouses (
    id NUMBER GENERATED BY DEFAULT ON NULL AS IDENTITY PRIMARY KEY,
    address VARCHAR2(200) NOT NULL,
    postcode VARCHAR2(20) NOT NULL
);

CREATE TABLE inventories(
    id NUMBER GENERATED BY DEFAULT ON NULL AS IDENTITY,
    warehouse_id NUMBER NOT NULL,
    product_id NUMBER NOT NULL,
    quantity NUMBER NOT NULL,
    inventory_date DATE NOT NULL
);

--altering (changing) tables -> adding constraints
ALTER TABLE employees ADD (
    FOREIGN KEY (department_id) REFERENCES departments(id),
    FOREIGN KEY (supervisor_id) REFERENCES employees(id)
);

ALTER TABLE managers ADD (
   FOREIGN KEY (employee_id) REFERENCES employees(id)
);

ALTER TABLE dependents ADD (
   FOREIGN KEY (employee_id) REFERENCES employees(id)
);

ALTER TABLE departments ADD (
   FOREIGN KEY (manager_id) REFERENCES managers(id)
);

ALTER TABLE locations ADD (
    FOREIGN KEY (department_id) REFERENCES departments(id)
);

ALTER TABLE projects ADD (
   FOREIGN KEY (location_id) REFERENCES locations(id)
);

ALTER TABLE project_assigmnents ADD (
   FOREIGN KEY (employee_id) REFERENCES employees(id),
   FOREIGN KEY (project_id) REFERENCES projects(id),
   CONSTRAINT pk1 PRIMARY KEY ( employee_id, project_id )
);

ALTER TABLE customers ADD (
    FOREIGN KEY (employee_id) REFERENCES employees(id)
);

ALTER TABLE orders ADD (
    FOREIGN KEY (customer_id) REFERENCES customers(id),
    FOREIGN KEY (product_id) REFERENCES products(id)
);

ALTER TABLE inventories ADD (
    FOREIGN KEY (warehouse_id) REFERENCES warehouses(id),
    FOREIGN KEY (product_id) REFERENCES products(id),
    CONSTRAINT pk2 PRIMARY KEY (product_id, warehouse_id)
);
