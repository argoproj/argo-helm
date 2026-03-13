FROM python:3.13-slim
WORKDIR /app
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

COPY main.py fetch_releases.py fetch_helmet_releases.py merge_csvs.py plot_graph.py ./
RUN chmod +x main.py fetch_releases.py fetch_helmet_releases.py merge_csvs.py plot_graph.py
CMD [ "python", "-u", "./main.py" ]
