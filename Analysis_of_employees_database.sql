
# In-depth analysis of an employees database.

## Background:-
## Conducted research on employees working in the 1980s,1990s and early 2000s at the fictional company using 6 CSV files containing various data,
## including: title, department name, employee numbers, employee names, salary and hire dates.



-- List the following details of each employee: 
-- employee number, last name, first name, gender, and salary.

SELECT emp.emp_no as employee_number, emp.last_name, emp.first_name, emp.gender, sal.salary
FROM employees as emp
LEFT JOIN salaries as sal
ON emp.emp_no = sal.emp_no
ORDER BY emp.emp_no;



-- List first name, last name, and hire date for employees who were hired in 1986.
SELECT first_name, last_name, hire_date
FROM employees
WHERE hire_date BETWEEN '1986-01-01' AND '1986-12-31';


-- List the manager of each department with the following information: 
-- department number, department name, the manager's employee number, last name, first name.

SELECT d.dept_no, d.dept_name, dm.emp_no, e.last_name, e.first_name
FROM departments d 
JOIN dept_manager dm ON (d.dept_no = dm.dept_no)
JOIN employees e ON (dm.emp_no = e.emp_no);


-- List the department of each employee with the following information: 
-- employee number, last name, first name, and department name.

SELECT e.emp_no, e.last_name, e.first_name, d.dept_name
FROM employees e
JOIN dept_emp de ON (e.emp_no = de.emp_no)
JOIN departments d ON (de.dept_no = d.dept_no);


-- List first name, last name, and gender for employees whose first name is "Hercules" and last names begin with "B."

SELECT first_name, last_name, gender
FROM employees 
WHERE first_name = 'Hercules'
AND last_name LIKE 'B%';


-- List all employees in the Sales department, including their employee number, last name, first name, and department name.

SELECT e.emp_no, e.last_name, e.first_name, d.dept_name
FROM employees e 
JOIN dept_emp de ON (e.emp_no = de.emp_no)
JOIN departments d ON (de.dept_no = d.dept_no)
WHERE d.dept_name = 'Sales';


-- List all employees in the Sales and Development departments, including their employee number, last name, first name, and department name.

SELECT e.emp_no, e.last_name, e.first_name, d.dept_name
FROM employees e 
JOIN dept_emp de ON (e.emp_no = de.emp_no)
JOIN departments d ON (de.dept_no = d.dept_no)
WHERE d.dept_name = 'Sales' 
OR d.dept_name = 'Development';


-- In descending order, list the frequency count of employee last names, i.e., how many employees share each last name.

SELECT count(last_name) as frequency, last_name
FROM employees
GROUP BY last_name
ORDER BY COUNT(last_name) DESC;


-- How many departments are there in the “employees” database? Use the ‘dept_emp’ table to answer the question.

SELECT 
    COUNT(DISTINCT dept_no)
FROM
    dept_emp;


-- What is the total amount of money spent on salaries for all contracts starting after the 1st of January 1997?

SELECT 
    SUM(salary)
FROM
    salaries
WHERE
    from_date > '1997-01-01';
       

-- Write a SQL query to retrieve all details of employees whose last name is 'Markovitch' and who are also managers listed in the dept_manager table. Ensure that the result includes all columns from the employees table.

SELECT 
    e.emp_no,
    e.first_name,
    e.last_name,
    dm.dept_no,
    dm.from_date
FROM
    employees e
        LEFT JOIN
    dept_manager dm ON e.emp_no = dm.emp_no
WHERE
    e.last_name = 'Markovitch'
ORDER BY dm.dept_no DESC , e.emp_no;



-- Write a SQL query to retrieve the first name, last name, hire date, and job title of all employees whose first name is "Margareta" and have the last name "Markovitch".


SELECT 
    e.first_name, e.last_name, e.hire_date, t.title
FROM
    employees e
        JOIN
    titles t ON e.emp_no = t.emp_no
WHERE
    first_name = 'Margareta'
        AND last_name = 'Markovitch'
ORDER BY e.emp_no
;   


-- Write a SQL query to retrieve all managers' first names, last names, hire dates, job titles, start dates, and department names.

SELECT 
    e.first_name,
    e.last_name,
    e.hire_date,
    t.title,
    m.from_date,
    d.dept_name
FROM
    employees e
        JOIN
    dept_manager m ON e.emp_no = m.emp_no
        JOIN
    departments d ON m.dept_no = d.dept_no
        JOIN
    titles t ON e.emp_no = t.emp_no
WHERE
    t.title = 'Manager'
ORDER BY e.emp_no;

-- Write a SQL query to retrieve information about all department managers who were hired between January 1, 1990, and January 1, 1995. The information should include the managers' first names, last names, hire dates, start dates, and department names.

SELECT 
    *
FROM
    dept_manager
WHERE
    emp_no IN (SELECT 
            emp_no
        FROM
            employees
        WHERE
            hire_date BETWEEN '1990-01-01' AND '1995-01-01');
            
            
-- Write a SQL stored procedure named emp_info_ that accepts two parameters: the first name and the last name of an individual. The procedure should return the employee number of the individual from the employees table.

DELIMITER $$

CREATE PROCEDURE emp_info_(in p_first_name varchar(255), in p_last_name varchar(255), out p_emp_no integer)

BEGIN
                SELECT

                                e.emp_no

                INTO p_emp_no FROM

                                employees e

                WHERE

                                e.first_name = p_first_name

                                                AND e.last_name = p_last_name;

END$$

DELIMITER ;        

set @p_emp_no = 0;
call employees.emp_info_('Aruna', 'Journel', @p_emp_no);
select @p_emp_no;

-- Write a SQL stored procedure named emp_info that takes two parameters: the first name and the last name of an employee. The procedure should return the salary from the most recent contract of that employee.






DELIMITER $$

CREATE FUNCTION emp_info(p_first_name varchar(255), p_last_name varchar(255)) RETURNS decimal(10,2)
DETERMINISTIC
BEGIN

                DECLARE v_max_from_date date;

    DECLARE v_salary decimal(10,2);

SELECT 
    MAX(from_date)
INTO v_max_from_date FROM
    employees e
        JOIN
    salaries s ON e.emp_no = s.emp_no
WHERE
    e.first_name = p_first_name
        AND e.last_name = p_last_name;

SELECT 
    s.salary
INTO v_salary FROM
    employees e
        JOIN
    salaries s ON e.emp_no = s.emp_no
WHERE
    e.first_name = p_first_name
        AND e.last_name = p_last_name
        AND s.from_date = v_max_from_date;

           

                RETURN v_salary;

END$$

DELIMITER ;

SELECT emp_info('Aruna', 'Journel');    