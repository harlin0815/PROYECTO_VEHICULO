import os
from fastapi import FastAPI, Body, HTTPException, status
from fastapi.responses import Response, JSONResponse
from fastapi.encoders import jsonable_encoder
from pydantic import BaseModel, Field, EmailStr
from bson import ObjectId
from typing import Optional, List
import motor.motor_asyncio
import pymongo

app = FastAPI()
client = motor.motor_asyncio.AsyncIOMotorClient(os.environ["MONGODB_URL"])
db = client.misiontic1867


class PyObjectId(ObjectId):
    @classmethod
    def _get_validators_(cls):
        yield cls.validate

    @classmethod
    def validate(cls, v):
        if not ObjectId.is_valid(v):
            raise ValueError("Invalid objectid")
        return ObjectId(v)

    @classmethod
    def _modify_schema_(cls, field_schema):
        field_schema.update(type="string")


class clienteModel(BaseModel):
    id: PyObjectId = Field(default_factory=PyObjectId, alias="_id")
    nombre: str = Field(...)
    apellido: str = Field(...)
    telefono: int= Field(...)
    email: EmailStr = Field(...)
    

    class Config:
        allow_population_by_field_name = True
        arbitrary_types_allowed = True
        json_encoders = {ObjectId: str}
        schema_extra = {
            "example": {
                "nombre": "harlin",
                "apellido": "wilches",
                "email": "jdoe@example.com",
                "telefono":"3136587782"
                
            }
        }


class UpdateclienteModel(BaseModel):
    name: Optional[str]
    apellido: Optional[str]
    email: Optional[EmailStr]
    telefono: Optional[int]

    class Config:
        arbitrary_types_allowed = True
        json_encoders = {ObjectId: str}
        schema_extra = {
            "example": {
                "name": "Jane Doe",
                "email": "jdoe@example.com",
                "course": "Experiments, Science, and Fashion in Nanophotonics",
                "edad": "25",
            }
        }


@app.post("/", response_description="Add new cliente", response_model=clienteModel)
async def create_cliente(cliente: clienteModel = Body(...)):
    cliente = jsonable_encoder(cliente)
    new_cliente= await db["misiontic"].insert_one(cliente)
    created_cliente = await db["misiontic"].find_one({"_id": new_cliente.inserted_id})
    return JSONResponse(status_code=status.HTTP_201_CREATED, content=created_cliente)


@app.get(
"/", response_description="List all cliente", response_model=List[clienteModel]
)
async def list_cliente():
    students = await db["misiontic"].find().to_list(1000)
    return students


@app.get(
    "/{id}", response_description="Get a single cliente", response_model=clienteModel
)
async def show_cliente(id: str):
    if (student := await db["misiontic"].find_one({"_id": id})) is not None:
        return student

    raise HTTPException(status_code=404, detail=f"cliente {id} not found")


@app.put("/{id}", response_description="Update a cliente", response_model=clienteModel)
async def update_student(id: str, cliente: UpdateclienteModel = Body(...)):
    cliente = {k: v for k, v in cliente.dict().items() if v is not None}

    if len(cliente) >= 1:
        update_result = await db["misiontic"].update_one({"_id": id}, {"$set": cliente})

        if update_result.modified_count == 1:
            if (
                updated_cliente := await db["misiontic"].find_one({"_id": id})
            ) is not None:
                return updated_cliente

    if (existing_cliente := await db["tripulante"].find_one({"_id": id})) is not None:
        return existing_cliente

    raise HTTPException(status_code=404, detail=f"cliente {id} not found")


@app.delete("/{id}", response_description="Delete a cliente")
async def delete_cliente(id: str):
    delete_result = await db["cliente"].delete_one({"_id": id})

    if delete_result.deleted_count == 1:
        return Response(status_code=status.HTTP_204_NO_CONTENT)

    raise HTTPException(status_code=404, detail=f"cliente {id} not found")
