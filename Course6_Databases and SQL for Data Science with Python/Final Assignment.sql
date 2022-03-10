--Exercise 1: Using Joins
--Q1:Write and execute a SQL query to list the school names, community 
--names and average attendance for communities with a hardship index of 98.
SELECT NAME_OF_SCHOOL, CD.COMMUNITY_AREA_NAME, AVERAGE_STUDENT_ATTENDANCE, 
	AVERAGE_TEACHER_ATTENDANCE
FROM CHICAGO_PUBLIC_SCHOOLS CPS INNER JOIN CENSUS_DATA CD
	ON CPS.COMMUNITY_AREA_NUMBER = CD.COMMUNITY_AREA_NUMBER
WHERE HARDSHIP_INDEX = 98

--Q2:Write and execute a SQL query to list all crimes that took place at a 
--school. Include case number, crime type and community name.
SELECT CASE_NUMBER, PRIMARY_TYPE, COMMUNITY_AREA_NAME
FROM CHICAGO_PUBLIC_SCHOOLS CPS RIGHT JOIN CHICAGO_CRIME_DATA CCD
	ON CPS.COMMUNITY_AREA_NUMBER = CCD.COMMUNITY_AREA_NUMBER
WHERE LOCATION_DESCRIPTION LIKE '%SCHOOL%'

--Exercise 2: Creating a View
--For privacy reasons, you have been asked to create a view that enables 
--users to select just the school name and the icon fields from the 
--CHICAGO_PUBLIC_SCHOOLS table. By providing a view, you can ensure that 
--users cannot see the actual scores given to a school, just the icon 
--associated with their score. You should define new names for the view 
--columns to obscure the use of scores and icons in the original table.
--Q3:Write and execute a SQL statement to create a view showing the 
--columns listed in the following table, with new column names as shown 
--in the second column.
CREATE VIEW CSP (School_Name, Safety_Rating, Family_Rating, 
	Environment_Rating,	Instruction_Rating, Leaders_Rating, 
	Teachers_Rating) AS
SELECT NAME_OF_SCHOOL, Safety_Icon, Family_Involvement_Icon, 
	Environment_Icon, Instruction_Icon, Leaders_Icon, Teachers_Icon
FROM CHICAGO_PUBLIC_SCHOOLS

SELECT * FROM CSP;

--Exercise 3: Creating a Stored Procedure
--The icon fields are calculated based on the value in the corresponding 
--score field. You need to make sure that when a score field is updated, 
--the icon field is updated too. To do this, you will write a stored 
--procedure that receives the school id and a leaders score as input 
--parameters, calculates the icon setting and updates the fields 
--appropriately.
--Q4: Write the structure of a query to create or replace a stored 
--procedure called UPDATE_LEADERS_SCORE that takes a in_School_ID 
--parameter as an integer and a in_Leader_Score parameter as an integer. 
--Don't forget to use the #SET TERMINATOR statement to use the @ for the 
--CREATE statement terminator.	

--#SET TERMINATOR @
CREATE PROCEDURE UPDATE_LEADERS_SCORE ( 
    IN in_School_ID INTEGER, IN in_Leader_Score INTEGER)    
    
--Q5: Inside your stored procedure, write a SQL statement to update the 
--Leaders_Score field in the CHICAGO_PUBLIC_SCHOOLS table for the school 
--identified by in_School_ID to the value in the in_Leader_Score 
--parameter.
--#SET TERMINATOR @
CREATE PROCEDURE UPDATE_LEADERS_SCORE ( 
    IN in_School_ID INTEGER, IN in_Leader_Score INTEGER)   
LANGUAGE SQL                                                
MODIFIES SQL DATA                                          

BEGIN 
                          
    UPDATE CHICAGO_PUBLIC_SCHOOLS
    SET LEADERS_SCORE = in_Leader_Score
    WHERE SCHOOL_ID = in_School_ID;  

END
@   

--Q6: Inside your stored procedure, write a SQL IF statement to update the Leaders_Icon field in the CHICAGO_PUBLIC_SCHOOLS table for the school 
--identified by in_School_ID using the following information.
--#SET TERMINATOR @
CREATE PROCEDURE UPDATE_LEADERS_SCORE ( 
    IN in_School_ID INTEGER, IN in_Leader_Score INTEGER)   
LANGUAGE SQL                                                
MODIFIES SQL DATA                                          

BEGIN 
                          
    UPDATE CHICAGO_PUBLIC_SCHOOLS
    SET LEADERS_SCORE = in_Leader_Score
    WHERE SCHOOL_ID = in_School_ID;  
    
    IF in_Leader_Score > 0 AND in_Leader_Score < 20 THEN              
        UPDATE CHICAGO_PUBLIC_SCHOOLS
        SET LEADERS_ICON = 'Very weak'
        WHERE SCHOOL_ID = in_School_ID;
    
    ELSEIF in_Leader_Score < 40 THEN                         
        UPDATE CHICAGO_PUBLIC_SCHOOLS
        SET LEADERS_ICON = 'Weak'
        WHERE SCHOOL_ID = in_School_ID;
    
    ELSEIF in_Leader_Score < 60 THEN                         
        UPDATE CHICAGO_PUBLIC_SCHOOLS
        SET LEADERS_ICON = 'Average'
        WHERE SCHOOL_ID = in_School_ID;
    
    ELSEIF in_Leader_Score < 80 THEN                         
        UPDATE CHICAGO_PUBLIC_SCHOOLS
        SET LEADERS_ICON = 'Strong'
        WHERE SCHOOL_ID = in_School_ID;
    
    ELSEIF in_Leader_Score < 100 THEN                         
        UPDATE CHICAGO_PUBLIC_SCHOOLS
        SET LEADERS_ICON = 'Very strong'
        WHERE SCHOOL_ID = in_School_ID;

    END IF;                          

END
@                                                       

DROP PROCEDURE UPDATE_LEADERS_SCORE;

--Q7: Run your code to create the stored procedure.
ALTER TABLE CHICAGO_PUBLIC_SCHOOLS 
	ALTER COLUMN LEADERS_ICON 
	SET DATA TYPE VARCHAR(20);

CALL UPDATE_LEADERS_SCORE(400018, 50);

SELECT SCHOOL_ID, LEADERS_SCORE, LEADERS_ICON
FROM CHICAGO_PUBLIC_SCHOOLS
WHERE School_ID = 400018

--Exercise 4: Using Transactions
--You realise that if someone calls your code with a score outside of the
--allowed range (0-99), then the score will be updated with the invalid 
--data and the icon will remain at its previous value. There are various 
--ways to avoid this problem, one of which is using a transaction.
--Q8: Update your stored procedure definition. Add a generic ELSE clause to the IF statement that rolls back the current work if the score did not fit any of the preceding categories.
--#SET TERMINATOR @
CREATE PROCEDURE UPDATE_LEADERS_SCORE ( 
    IN in_School_ID INTEGER, IN in_Leader_Score INTEGER)   
LANGUAGE SQL                                                
MODIFIES SQL DATA                                          

BEGIN 
                          
    UPDATE CHICAGO_PUBLIC_SCHOOLS
    SET LEADERS_SCORE = in_Leader_Score
    WHERE SCHOOL_ID = in_School_ID;  
    
    IF in_Leader_Score > 0 AND in_Leader_Score < 20 THEN              
        UPDATE CHICAGO_PUBLIC_SCHOOLS
        SET LEADERS_ICON = 'Very weak'
        WHERE SCHOOL_ID = in_School_ID;
    
    ELSEIF in_Leader_Score < 40 THEN                         
        UPDATE CHICAGO_PUBLIC_SCHOOLS
        SET LEADERS_ICON = 'Weak'
        WHERE SCHOOL_ID = in_School_ID;
    
    ELSEIF in_Leader_Score < 60 THEN                         
        UPDATE CHICAGO_PUBLIC_SCHOOLS
        SET LEADERS_ICON = 'Average'
        WHERE SCHOOL_ID = in_School_ID;
    
    ELSEIF in_Leader_Score < 80 THEN                         
        UPDATE CHICAGO_PUBLIC_SCHOOLS
        SET LEADERS_ICON = 'Strong'
        WHERE SCHOOL_ID = in_School_ID;
    
    ELSEIF in_Leader_Score < 100 THEN                         
        UPDATE CHICAGO_PUBLIC_SCHOOLS
        SET LEADERS_ICON = 'Very strong'
        WHERE SCHOOL_ID = in_School_ID;
    ELSE 
    	ROLLBACK WORK;

    END IF;                          
	
END
@  

--Q9: Update your stored procedure definition again. Add a statement to commit the current unit of work at the end of the procedure.
--#SET TERMINATOR @
CREATE PROCEDURE UPDATE_LEADERS_SCORE ( 
    IN in_School_ID INTEGER, IN in_Leader_Score INTEGER)   
LANGUAGE SQL                                                
MODIFIES SQL DATA                                          

BEGIN 
                          
    UPDATE CHICAGO_PUBLIC_SCHOOLS
    SET LEADERS_SCORE = in_Leader_Score
    WHERE SCHOOL_ID = in_School_ID;  
    
    IF in_Leader_Score > 0 AND in_Leader_Score < 20 THEN              
        UPDATE CHICAGO_PUBLIC_SCHOOLS
        SET LEADERS_ICON = 'Very weak'
        WHERE SCHOOL_ID = in_School_ID;
    
    ELSEIF in_Leader_Score < 40 THEN                         
        UPDATE CHICAGO_PUBLIC_SCHOOLS
        SET LEADERS_ICON = 'Weak'
        WHERE SCHOOL_ID = in_School_ID;
    
    ELSEIF in_Leader_Score < 60 THEN                         
        UPDATE CHICAGO_PUBLIC_SCHOOLS
        SET LEADERS_ICON = 'Average'
        WHERE SCHOOL_ID = in_School_ID;
    
    ELSEIF in_Leader_Score < 80 THEN                         
        UPDATE CHICAGO_PUBLIC_SCHOOLS
        SET LEADERS_ICON = 'Strong'
        WHERE SCHOOL_ID = in_School_ID;
    
    ELSEIF in_Leader_Score < 100 THEN                         
        UPDATE CHICAGO_PUBLIC_SCHOOLS
        SET LEADERS_ICON = 'Very strong'
        WHERE SCHOOL_ID = in_School_ID;
    ELSE 
    	ROLLBACK WORK;

    END IF;                          
	COMMIT WORK;
END
@  