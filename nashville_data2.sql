#Cleaning data in SQL queries.
# Limpiando los datos en los queries de SQL
SELECT * FROM nashvilleproject.nashville_data
order by saledate desc;
------------------------------------------------------------------------------

#Change Date format.
#Cambiar el formato a fecha
UPDATE nashvilleproject.nashville_data
SET SaleDate = STR_TO_DATE(SaleDate, '%d/%m/%Y');

------------------------------------------------------------------------------

# Populate Property Address Data, where data is null, with the data of the Property Address, who shares the same
#ParcelID, but different UniqueID, implying that they were different transactions in the same location.
# LLenar la columna de Property Address, donde los datos estaban nulos, con los datos de Property Address que compartían el mismo 
# ParcelID, pero distinto UniqueID, dando a entender que eran transacciones diferentes pero en la misma casa.

# (the IFNULL (a.PropertyAddress,b.PropertyAddress) checks if a.PropertyAddress is null,
#  and if it is, it returns b.PropertyAddress. If a.PropertyAddress is not null, it returns a.PropertyAddress.)
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID,b.PropertyAddress, IFNULL(a.PropertyAddress,b.PropertyAddress)
FROM nashvilleproject.nashville_data a
join nashvilleproject.nashville_data b
on a.ParcelID = b.ParcelID
and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null;

# Updating the table with the missing data
# Actualizando la tabla con la información faltante.

UPDATE nashvilleproject.nashville_data a
JOIN nashvilleproject.nashville_data b
ON a.ParcelID = b.ParcelID 
AND a.UniqueID <> b.UniqueID
SET a.PropertyAddress = IFNULL(a.PropertyAddress, b.PropertyAddress)
WHERE a.PropertyAddress IS NULL;

-- checking the changes, 0 rows should be returned if the update work
-- revisando si los cambios funcionaron
select nashville_data.PropertyAddress
from nashville_data
where PropertyAddress is null;
------------------------------------------------------------------------------

-- Break out address into Individual  Columns (Adress, City)  from PropertyAddress
-- Separar las direcciones, en columnas individuales, para la columna PropertyAddress
SELECT * FROM nashvilleproject.nashville_data;

SELECT 
SUBSTRING_INDEX(PropertyAddress, ",", 1) AS Address,
SUBSTRING_INDEX(PropertyAddress,",",-1) as City
FROM nashvilleproject.nashville_data;

ALTER TABLE nashville_data
ADD COLUMN PropertyAdressSplit VARCHAR(255) AFTER PropertyAddress;

ALTER TABLE nashville_data
ADD COLUMN PropertyCitySplit VARCHAR(255) AFTER PropertyAdressSplit;

update nashville_data
set PropertyAdressSplit = SUBSTRING_INDEX(PropertyAddress, ",", 1);

update nashville_data
set PropertyCitySplit = SUBSTRING_INDEX(PropertyAddress,",",-1);

alter table nashville_data
drop column PropertyAddress;
------------------------------------------------------------------------------

-- Break out address into Individual  Columns (Adress, City, State) from OwnerAdress
-- Lo mismo que lo anterior, pero acá tenemos una string separada por tres comas.
SELECT * FROM nashvilleproject.nashville_data;

select 
substring_index(OwnerAddress,",",1),
substring_index(substring_index(OwnerAddress,",",2),",",-1),
substring_index(OwnerAddress,",",-1)
from nashville_data;

alter table nashville_data
add column OwnerAdressSplit varchar(255) after OwnerAddress;
alter table nashville_data
add column OwnerCitySplit varchar(255) after OwnerAdressSplit;
alter table nashville_data
add column OwnerStSplit varchar(255) after OwnerCitySplit;

update nashville_data
set OwnerAdressSplit = substring_index(OwnerAddress,",",1);
update nashville_data
set OwnerCitySplit = substring_index(substring_index(OwnerAddress,",",2),",",-1);
update nashville_data
set OwnerCitySt = substring_index(OwnerAddress,",",-1);
------------------------------------------------------------------------------

-- Change N and Y to No and Yes in the "SoldAsVacant" Column
-- Cambiando las letras N y Y por Yes y No, en la columna SoldAsVacant.
select distinct soldasvacant, count(soldasvacant)
from nashville_data
group by soldasvacant;


select SoldAsVacant,
case 
	when SoldAsVacant = "Y" Then "Yes"
	when SoldAsVacant = "N" Then "No"
	ELSE SoldAsVacant
END as SoldasVacantUpdate
from nashville_data;


update nashville_data
set SoldAsVacant = case 
	when SoldAsVacant = "Y" Then "Yes"
	when SoldAsVacant = "N" Then "No"
	ELSE SoldAsVacant
END;
------------------------------------------------------------------------------

-- Remove Duplicates (normally doesn't do this in SQL)
-- if there is rows with the same parcelid,propertyaddress,saleprice,saledate and legalreference, it will tell us with row_number()
-- Removiendo duplicados.

with RowNumCTE as(
SELECT *, 
   ROW_NUMBER() OVER (
      PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
      ORDER BY UniqueID
   ) AS row_num
FROM nashville_data
)
select * 
from RowNumCTE
where row_num > 1;

-- ........deleting.........
-- Borrando.

DELETE FROM nashville_data
WHERE UniqueID IN (
   SELECT UniqueID
   FROM (
      SELECT UniqueID, 
         ROW_NUMBER() OVER (
            PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
            ORDER BY UniqueID
         ) AS row_num
      FROM nashville_data
   ) t
   WHERE row_num > 1
);

------------------------------------------------------------------------------

-- Delete Unused Columns
-- Borrar columnas que no sirven.
SELECT * FROM nashvilleproject.nashville_data;

alter table nashville_data
drop column PropertyAddress;

alter table nashville_data
drop column OwnerAddress;

alter table nashville_data
drop column TaxDistrict;
------------------------------------------------------------------------------






