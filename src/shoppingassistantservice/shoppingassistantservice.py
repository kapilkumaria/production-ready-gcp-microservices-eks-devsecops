#!/usr/bin/python
#
# Copyright 2024 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

import os
from urllib.parse import unquote
from flask import Flask, request

from langchain_core.messages import HumanMessage
from langchain_google_genai import ChatGoogleGenerativeAI, GoogleGenerativeAIEmbeddings

# --------------------------------------------------------------------
# AWS-SAFE MODE — All GCP dependencies removed
# --------------------------------------------------------------------

# Environment variables (fallback defaults so nothing crashes)
PROJECT_ID = os.getenv("PROJECT_ID", "demo-project")
REGION = os.getenv("REGION", "us-east-1")
ALLOYDB_DATABASE_NAME = os.getenv("ALLOYDB_DATABASE_NAME", "dummy-db")
ALLOYDB_TABLE_NAME = os.getenv("ALLOYDB_TABLE_NAME", "dummy-table")
ALLOYDB_CLUSTER_NAME = os.getenv("ALLOYDB_CLUSTER_NAME", "dummy-cluster")
ALLOYDB_INSTANCE_NAME = os.getenv("ALLOYDB_INSTANCE_NAME", "dummy-instance")
ALLOYDB_SECRET_NAME = os.getenv("ALLOYDB_SECRET_NAME", "dummy-secret")

print("==============================================")
print(" Running ShoppingAssistantService in AWS-SAFE MODE")
print(" No GCP Secret Manager, No AlloyDB connections")
print("==============================================")

# Disable GCP Secret Manager and AlloyDB
PGPASSWORD = "dummy-password"
engine = None
vectorstore = None


# --------------------------------------------------------------------
# Flask App
# --------------------------------------------------------------------
def create_app():
    app = Flask(__name__)

    @app.route("/", methods=['POST'])
    def talkToGemini():
        print("Beginning RAG call (AWS safe mode)")

        # Extract prompt input
        prompt = request.json.get('message', '')
        prompt = unquote(prompt)

        # Extract image URL
        image_url = request.json.get('image')

        # Step 1 — Call Gemini Vision to describe the image
        try:
            llm_vision = ChatGoogleGenerativeAI(model="gemini-1.5-flash")
            message = HumanMessage(
                content=[
                    {"type": "text",
                     "text": "You are a professional interior designer. Describe this room."},
                    {"type": "image_url", "image_url": image_url},
                ]
            )
            response = llm_vision.invoke([message])
            description_response = response.content
            print("Description Response:", description_response)

        except Exception as e:
            print("Gemini Vision error:", e)
            description_response = "Unable to analyze image in this environment."

        # Step 2 — Vector Search (DISABLED)
        print("Vector search disabled in AWS-safe mode")
        docs = []
        relevant_docs = ""

        # Step 3 — Final recommendation prompt
        design_prompt = (
            f"Room description: {description_response}\n"
            f"User request: {prompt}\n"
            f"Relevant items: {relevant_docs}\n"
            f"Provide interior design recommendations."
        )

        print("Final design prompt:", design_prompt)

        try:
            llm = ChatGoogleGenerativeAI(model="gemini-1.5-flash")
            design_response = llm.invoke(design_prompt)
            output_text = design_response.content

        except Exception as e:
            print("Gemini Text error:", e)
            output_text = "Unable to generate recommendations in this environment."

        return {"content": output_text}

    return app


# --------------------------------------------------------------------
# Main entrypoint
# --------------------------------------------------------------------
if __name__ == "__main__":
    app = create_app()
    app.run(host='0.0.0.0', port=8080)
