-- Create employees table
create table employees (
	emp_no INT PRIMARY KEY NOT NULL,
	birth_date DATE NOT NULL,
	first_name VARCHAR(35) NOT NULL,
	last_name VARCHAR(35) NOT NULL,
	gender VARCHAR(1)NOT NULL,
	hire_date DATE NOT NULL
);

-- Create departments table
create table departments (
	dept_no VARCHAR(8) primary key NOT NULL,
	dept_name VARCHAR(40) NOT NULL
);

-- Create titles table
create table titles (
	emp_no INT NOT NULL,
	title VARCHAR(40) NOT NULL,
	from_date DATE NOT NULL,
	to_date DATE NOT NULL,
    foreign key (emp_no) references employees (emp_no)
);

-- Create department employee table
create table dept_emp (
	emp_no INT NOT NULL,
	dept_no VARCHAR(8) NOT NULL,
	from_date DATE NOT NULL,
	to_date DATE NOT NULL,
    foreign key (emp_no) references employees (emp_no),
    foreign key (dept_no) references departments (dept_no)
);

-- Create salaries table
create table salaries (
	emp_no INT NOT NULL,
	salary INT NOT NULL,
	from_date DATE NOT NULL,
	to_date DATE NOT NULL,
    foreign key (emp_no) references employees (emp_no)
);

-- Create Department manager table
create table dept_manager (
	dept_no VARCHAR(8) NOT NULL,
	emp_no INT NOT NULL,
	from_date DATE NOT NULL,
	to_date DATE NOT NULL,
    foreign key (emp_no) references employees (emp_no),
    foreign key (dept_no) references departments (dept_no)
);

-- Change to_date years that hold year 9999 to current date for dept_manager,
-- dept emp, and titles (salaries table does not have 9999 year)
update dept_manager
set to_date = CURRENT_DATE
where extract(year from to_date) = 9999;

update dept_emp
set to_date = CURRENT_DATE
where extract(year from to_date) = 9999;

update titles
set to_date = CURRENT_DATE
where extract(year from to_date) = 9999;

--1. List the following details of each employee:
-- employee number, last name, first name, gender, and salary.
-- from employees: employee number (emp_no), last name (last_name), first name (first_name), gender
-- from salaries: employee number (emp_no), salary
select s.emp_no, e.last_name, e.first_name, e.gender, s.salary
from employees as e
inner join salaries as s
on s.emp_no = e.emp_no
order by s.emp_no;


-- 2. List employees who were hired in 1986
select emp_no, last_name, first_name, hire_date 
from employees 
where extract(year from hire_date) = 1986;

-- 3. List the manager of each department with the following information:
-- department number, department name, the manager's employee number, 
-- last name, first name, and start and end employment dates.
select distinct on (dept_manager.dept_no) dept_manager.dept_no, departments.dept_name, dept_manager.emp_no, employees.last_name, employees.first_name,dept_manager.from_date, dept_manager.to_date
from dept_manager 
inner join departments 
on dept_manager.dept_no= departments.dept_no
inner join employees 
on dept_manager.emp_no = employees.emp_no
order by dept_manager.dept_no, dept_manager.to_date DESC;

-- 4. List the department of each employee with the following information: 
--employee number, last name, first name, and department name.
select distinct on (e.emp_no) e.emp_no, e.last_name, e.first_name,d.dept_name
from employees as e
left join dept_emp as de
on e.emp_no = de.emp_no
inner join departments as d
on de.dept_no = d.dept_no
order by e.emp_no, de.to_date DESC;



-- 5. List all employees whose first name is "Hercules" 
--and last names begin with "B.
select e.last_name, e.first_name
from employees as e
where (e.first_name = 'Hercules') and (lower(e.last_name) like 'b%')
order by e.last_name;


-- Create table with most current departments for each employee to use for #6 and #7 below:
select distinct on (emp_no) *
into current_dept_emp
from dept_emp
order by emp_no, to_date DESC;

-- 6.List all employees in the Sales department, including their employee number, 
--last name, first name, and department name.
select e.emp_no, e.last_name, e.first_name, d.dept_name
from employees as e
inner join current_dept_emp as cde
on e.emp_no = cde.emp_no
inner join departments as d
on cde.dept_no = d.dept_no
where lower(d.dept_name) = 'sales';

-- 7. List all employees in the Sales and Development departments, 
--including their employee number, last name, first name, and department name.
select e.emp_no, e.last_name, e.first_name, d.dept_name
from employees as e
inner join current_dept_emp as cde
on e.emp_no = cde.emp_no
inner join departments as d
on cde.dept_no = d.dept_no
where (lower(d.dept_name) = 'sales') or (lower(d.dept_name) = 'development');

-- 8. In descending order, list the frequency count of employee last names, 
-- i.e., how many employees share each last name.
select last_name,count(last_name) as Frequency 
from employees 
group by last_name
order by frequency desc;