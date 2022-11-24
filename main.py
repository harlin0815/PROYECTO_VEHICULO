from fastapi import FastAPI,HTTPException
from pydantic import BaseModel
from typing import Optional,Text 
from uuid import uuid4 as uuid
from datetime import datetime
import uvicorn
  
app=FastAPI()

paquetes=[]
class Paquete(BaseModel):
    id:Optional[str]
    Nombre:str
    Modelo:str
    Marca:str
    Fecha:datetime=datetime.now()

@app.get("/")
def root():
    return{"hola":"Bienvenido"}

@app.get("/paquetes")
def get_paquetes():
    return paquetes

@app.post("/paquetes")
def save_paquete(paquete:Paquete):
    paquetes.id=str(uuid)
    paquetes.append(paquetes.dict())
    return paquetes[-1]


@app.get("paquete/{paquetes_id}")
def save_paquete(paquetes_id:str):
    for post in paquetes:
      if paquetes["id"]== paquetes_id:
          return post

raise HTTPException(Status_code=404,detail="pagina no encontrada")

@app.delete("/paquetes/{paquetes_id}")
def delete_paquete(paquetes_id:str):
    for index, post in enumerate(paquetes):
        if post["id"]==paquetes_id:
         paquetes.pop(index)
         return{"el paquete fue eliminado"}   
    
@app.put("paquetes/{paquetes_id}")
def update_paquete(paquetes_id:str,updatePaquete:Paquete):
    for index, post in enumerate(paquetes):
         if paquetes["id"]== paquetes_id:
             paquetes[index][" Nombre"]=updatePaquete.dict()[" Nombre"]
    