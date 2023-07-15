-------Data Cleaning Process Using SQL--------------------
Select * from PortFolio_Project.dbo.NashVilleHousing;
------------------------------------------------------------
---------Changing date format of Date column---------------------
Select SaleDate from PortFolio_Project.dbo.NashVilleHousing;
Select SaleDate,CONVERT(date,SaleDate) from PortFolio_Project.dbo.NashVilleHousing;
update PortFolio_Project.dbo.NashVilleHousing set SaleDate=CONVERT(date,SaleDate);
alter table PortFolio_Project.dbo.NashVilleHousing add SaleDateConverted date;
update PortFolio_Project.dbo.NashVilleHousing set SaleDateConverted=CONVERT(date,SaleDate);
----------------------------------------------------------------------------
-----------------Populate Property Address---------------------------
Select PropertyAddress from PortFolio_Project.dbo.NashVilleHousing;
Select * from PortFolio_Project.dbo.NashVilleHousing where PropertyAddress is null;
Select a.ParcelID,a.PropertyAddress,b.ParcelID ,b.PropertyAddress ,isnull(a.PropertyAddress,b.PropertyAddress)
from PortFolio_Project.dbo.NashVilleHousing a
join PortFolio_Project.dbo.NashVilleHousing b
on a.ParcelID=b.ParcelID and a.[UniqueID] <> b.[UniqueID] where a.PropertyAddress is null;

update a set PropertyAddress=isnull(a.PropertyAddress,b.PropertyAddress) from PortFolio_Project.dbo.NashVilleHousing a
join PortFolio_Project.dbo.NashVilleHousing b
on a.ParcelID=b.ParcelID and a.[UniqueID] <> b.[UniqueID] where a.PropertyAddress is null;
------------------------PropertAddress Break down into(Address,State,City)------------------
Select PropertyAddress from PortFolio_Project.dbo.NashVilleHousing;
Select substring(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address,
 substring(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,len(PropertyAddress)) as city
from PortFolio_Project.dbo.NashVilleHousing;

alter table PortFolio_Project.dbo.NashVilleHousing add PropertySplitAddress varchar(200);
update PortFolio_Project.dbo.NashVilleHousing set PropertySplitAddress=substring(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) ;
alter table PortFolio_Project.dbo.NashVilleHousing add PropertySplitCity varchar(200);
update PortFolio_Project.dbo.NashVilleHousing set PropertySplitCity= substring(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,len(PropertyAddress));

Select * from PortFolio_Project.dbo.NashVilleHousing;
------------------------OwnerAddress Break down into(Address,State,City)------------------

Select OwnerAddress from PortFolio_Project.dbo.NashVilleHousing;
select parsename(replace(OwnerAddress,',','.'),3),parsename(replace(OwnerAddress,',','.'),2),
parsename(replace(OwnerAddress,',','.'),1) 
from PortFolio_Project.dbo.NashVilleHousing;
alter table PortFolio_Project.dbo.NashVilleHousing add OwnerSplitAddress varchar(200);
update PortFolio_Project.dbo.NashVilleHousing set OwnerSplitAddress= parsename(replace(OwnerAddress,',','.'),3);
alter table PortFolio_Project.dbo.NashVilleHousing add OwnerSplitCity varchar(200);
update PortFolio_Project.dbo.NashVilleHousing set OwnerSplitCity= parsename(replace(OwnerAddress,',','.'),2);
alter table PortFolio_Project.dbo.NashVilleHousing add OwnerSplitState varchar(200);
update PortFolio_Project.dbo.NashVilleHousing set OwnerSplitState=parsename(replace(OwnerAddress,',','.'),1) ;
---------------Change Y/N to Yes and No in 'Sold as Vacant' field---
select *  from PortFolio_Project.dbo.NashVilleHousing;
select distinct(SoldAsVacant),count(SoldAsVacant) from PortFolio_Project.dbo.NashVilleHousing
group by SoldAsVacant
order by 2;

select SoldAsVacant,
CASE when SoldAsVacant='Y' then 'Yes'
     when SoldAsVacant='N' then 'No'
	 else SoldAsVacant
	 end
from PortFolio_Project.dbo.NashVilleHousing;

update PortFolio_Project.dbo.NashVilleHousing set SoldAsVacant=
CASE when SoldAsVacant='Y' then 'Yes'
     when SoldAsVacant='N' then 'No'
	 else SoldAsVacant
	 end
from PortFolio_Project.dbo.NashVilleHousing;

----------------------Remove Duplicates------------------------------------------
with RCTE as(
Select *,ROW_NUMBER() over(partition by ParcelID,PropertyAddress,
SalePrice,SaleDate,LegalReference order by UniqueID)rownum
from PortFolio_Project.dbo.NashVilleHousing)
Delete from RCTE where rownum >1;
--order by ParcelID
with RCTE as(
Select *,ROW_NUMBER() over(partition by ParcelID,PropertyAddress,
SalePrice,SaleDate,LegalReference order by UniqueID)rownum
from PortFolio_Project.dbo.NashVilleHousing)
 Select * from RCTE where rownum >1
order by ParcelID;
-------------------------------Delete Unused Columns--------------
Select * from PortFolio_Project.dbo.NashVilleHousing;
ALTER TABLE PortFolio_Project.dbo.NashVilleHousing
DROP COLUMN OwnerAddress,PropertyAddress,TaxDistrict,SaleDate;
Select * from PortFolio_Project.dbo.NashVilleHousing;
 









