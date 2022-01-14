/*==============create table indication=======================*/

Create table Indication (
drug_ID int not null,
In_ID int not null,
indication varchar(50) not null,
therapatic_area varchar(50) not null,
local_groups varchar(2) not null,
primary key (In_ID)
);

/*================== create table chemical combination=========================*/

create table Chemical_Combination (
chemical_combination_ID int not null,
chemical_combination varchar(50) not null,
c_name varchar (30) not null,
display_name varchar(50) not null,
primary key (chemical_combination_ID)
);

/*=====================creating table strength===============================*/

create table Strength (
drugstrength_ID int not null,
drug_ID int not null,
product_form_strength_name varchar(50) not null,
strengthin_MG varchar(20) not null,
strength_new int not null,
dosage_form varchar (30) not null,
primary key (drugstrength_ID)
);

/*========================creating table drugs=============================*/

create table Drugs(
drug_ID int not null,
drug_type varchar (30) not null,
drug_name varchar (30) not null,
comb_ID int not null,
primary key (drug_ID)
);

/*===============================adding foreign key to table============================*/

alter table Indication
add constraint FK_ind foreign key (drug_ID) references Drugs(drug_ID);

alter table Drugs
add constraint FK_drugs foreign key (comb_ID) references Chemical_Combination(chemical_combination_ID);

alter table Strength
add constraint FK_strength foreign key (drug_ID) references Drugs(drug_ID);


/*======================imported data for all tables with table data import wizard ==========================================*/

select * from Chemical_Combination;
select * from Drugs;
select * from Indication;
select * from Strength;

/*==========================creating view for finding local drugs============================================*/

create view Localbrand_drugs as
select drug_ID, drug_type, chemical_combination_ID, display_name
from Drugs, Chemical_combination
where comb_ID = chemical_combination_ID;

select * from Localbrand_drugs;

/*=====================================creating view for therapatic area of cardio and CNS===========================*/

create view Toptherapeutic_area as 
select i.therapatic_area, i.indication, d.drug_name
from Drugs as d, Indication as i
where d.drug_ID = i.drug_ID and i.therapatic_area = 'CARDIOVASCULAR, Cardiovascular' 
union
select i.therapatic_area, i.indication, d.drug_name
from Drugs as d, Indication as i
where d.drug_ID = i.drug_ID and i.therapatic_area = 'CNS, Central Nervous System' 
order by therapatic_area ;

select * from Toptherapeutic_area ;

/*=============================creating view for global drugs with low power==========================================*/

create view Globaldrug as
select d.drug_ID, d.drug_name, d.drug_type, s.strength_new, s.dosage_form
from Drugs as d, Strength as s
where d.drug_ID = s.drug_ID and s.strength_new < 51 ;

select * from Globaldrug;




/*=================================stored procedure for adding new drug and restrict addition of repetation of drugs============================================*/



delimiter //
CREATE PROCEDURE add_new_drug (in ndrug_ID int, in ndrug_type varchar(30), in ndrug_name varchar(30), in ncomb_ID int)
BEGIN
declare rowcount int;

	select count(*) into rowcount
	from Drugs
    where ndrug_name = drug_name;
    
    if (rowcount > 0 )
    then
    select 'Drug already exist !!' as Mesaage ;
    end if;
    
    if (rowcount = 0) 
    then
    insert into Drugs (drug_ID, drug_type, drug_name, comb_ID)
    values (ndrug_ID, ndrug_type, ndrug_name, ncomb_ID);
    select * from Drugs ;
end if;
END //
delimiter ;

call add_new_drug(58, 'what', 'opq', 104);

drop procedure if exists add_new_drug;


/*============================================creating triigger for non HP=======================================================*/

delimiter //
create trigger testing
before insert
on Indication
for each row

begin
if new.local_groups <> 'HP'
then
set new.local_groups = 'NA' , new.indication = 'NA', new.therapatic_area = 'NA' ;
end if;

end //
delimiter ;

insert into Indication (drug_ID, In_ID, indication, therapatic_area, local_groups)
values (14,4444, 'what', 'arr', 'HP');

drop trigger testing ;

delete from indication 
where In_ID = 4444 ;

/*===============================creating trigger on updation for tampered data (if someone wants to cahnge the data in current database then it should give indication )=====*/

delimiter //

create trigger tamper
before update
on Indication
for each row

begin
set new.indication = 'Tampered' ;
end //
delimiter ;

drop trigger tamper ;

update Indication 
set therapatic_area = 'nnn'
where drug_ID = 15 ;


/*====================================================================*/
